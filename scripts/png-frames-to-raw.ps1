param(
  [string]$FramesDir = (Join-Path $PSScriptRoot '..\walkthrough-assets\frames'),
  [string]$OutputFile = (Join-Path $PSScriptRoot '..\walkthrough-assets\frames.rgb24')
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @'
using System;
using System.IO;
using System.Runtime.InteropServices;

public static class WalkthroughPixelWriter
{
    public static void WriteRgb24(IntPtr scan0, int stride, int width, int height, Stream output)
    {
        int rowBytes = width * 3;
        byte[] source = new byte[rowBytes];
        byte[] row = new byte[rowBytes];
        for (int y = 0; y < height; y++)
        {
            Marshal.Copy(IntPtr.Add(scan0, y * stride), source, 0, rowBytes);
            for (int x = 0, target = 0; x < width; x++, target += 3)
            {
                int pixel = x * 3;
                row[target] = source[pixel + 2];
                row[target + 1] = source[pixel + 1];
                row[target + 2] = source[pixel];
            }
            output.Write(row, 0, row.Length);
        }
    }
}
'@

$files = Get-ChildItem -LiteralPath $FramesDir -Filter 'frame-*.png' -File | Sort-Object Name
if ($files.Count -eq 0) { throw "No PNG frames found in $FramesDir" }

$stream = [System.IO.File]::Open($OutputFile, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
try {
  foreach ($file in $files) {
    $source = [System.Drawing.Bitmap]::FromFile($file.FullName)
    try {
      $bitmap = New-Object System.Drawing.Bitmap($source.Width, $source.Height, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
      $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
      $graphics.DrawImageUnscaled($source, 0, 0)
      $graphics.Dispose()

      $rect = New-Object System.Drawing.Rectangle(0, 0, $bitmap.Width, $bitmap.Height)
      $data = $bitmap.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
      try {
        [WalkthroughPixelWriter]::WriteRgb24($data.Scan0, $data.Stride, $bitmap.Width, $bitmap.Height, $stream)
      } finally {
        $bitmap.UnlockBits($data)
      }
      $bitmap.Dispose()
    } finally {
      $source.Dispose()
    }
  }
} finally {
  $stream.Dispose()
}

$info = Get-Item -LiteralPath $OutputFile
Write-Output "Wrote $($files.Count) RGB24 frames ($($info.Length) bytes) to $OutputFile"
