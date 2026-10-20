param(
  [string]$OutputDir = (Join-Path $PSScriptRoot '..\walkthrough-assets\frames'),
  [int]$Width = 1280,
  [int]$Height = 720,
  [int]$Fps = 10
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$palette = @{
  Paper = [System.Drawing.ColorTranslator]::FromHtml('#fff3e8')
  Surface = [System.Drawing.ColorTranslator]::FromHtml('#fffaf5')
  Ink = [System.Drawing.ColorTranslator]::FromHtml('#402b40')
  Muted = [System.Drawing.ColorTranslator]::FromHtml('#796074')
  Dark = [System.Drawing.ColorTranslator]::FromHtml('#52334d')
  Berry = [System.Drawing.ColorTranslator]::FromHtml('#974363')
  Peach = [System.Drawing.ColorTranslator]::FromHtml('#f5c4aa')
  Citrus = [System.Drawing.ColorTranslator]::FromHtml('#f7c9b0')
  Lilac = [System.Drawing.ColorTranslator]::FromHtml('#eadce9')
  Line = [System.Drawing.ColorTranslator]::FromHtml('#dfc6cd')
  White = [System.Drawing.ColorTranslator]::FromHtml('#fffaf5')
}

if (Test-Path -LiteralPath $OutputDir) {
  Get-ChildItem -LiteralPath $OutputDir -Filter '*.png' -File | Remove-Item -Force
} else {
  New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

function New-Font([string]$family, [float]$size, [System.Drawing.FontStyle]$style = [System.Drawing.FontStyle]::Regular) {
  New-Object System.Drawing.Font($family, $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
}

function New-Brush([System.Drawing.Color]$color) {
  New-Object System.Drawing.SolidBrush($color)
}

function New-RoundPath([float]$x, [float]$y, [float]$w, [float]$h, [float]$radius) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $radius * 2
  $path.AddArc($x, $y, $d, $d, 180, 90)
  $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $path.CloseFigure()
  $path
}

function Fill-RoundRect($g, [System.Drawing.Color]$color, [float]$x, [float]$y, [float]$w, [float]$h, [float]$radius) {
  $brush = New-Brush $color
  $path = New-RoundPath $x $y $w $h $radius
  $g.FillPath($brush, $path)
  $path.Dispose(); $brush.Dispose()
}

function Stroke-RoundRect($g, [System.Drawing.Color]$color, [float]$width, [float]$x, [float]$y, [float]$w, [float]$h, [float]$radius) {
  $pen = New-Object System.Drawing.Pen($color, $width)
  $path = New-RoundPath $x $y $w $h $radius
  $g.DrawPath($pen, $path)
  $path.Dispose(); $pen.Dispose()
}

function Draw-Text($g, [string]$text, [float]$x, [float]$y, [float]$w, [float]$h, [float]$size, [System.Drawing.Color]$color, [string]$family = 'Segoe UI', [System.Drawing.FontStyle]$style = [System.Drawing.FontStyle]::Regular, [string]$align = 'Near') {
  $font = New-Font $family $size $style
  $brush = New-Brush $color
  $format = New-Object System.Drawing.StringFormat
  $format.Alignment = [System.Drawing.StringAlignment]::$align
  $format.LineAlignment = [System.Drawing.StringAlignment]::Near
  $format.Trimming = [System.Drawing.StringTrimming]::EllipsisWord
  $g.DrawString($text, $font, $brush, (New-Object System.Drawing.RectangleF($x, $y, $w, $h)), $format)
  $format.Dispose(); $brush.Dispose(); $font.Dispose()
}

function Draw-Pill($g, [string]$text, [float]$x, [float]$y, [float]$w, [System.Drawing.Color]$fill, [System.Drawing.Color]$ink) {
  Fill-RoundRect $g $fill $x $y $w 34 17
  Draw-Text $g $text $x ($y + 7) $w 24 13 $ink 'Segoe UI' ([System.Drawing.FontStyle]::Bold) 'Center'
}

function Draw-Button($g, [string]$text, [float]$x, [float]$y, [float]$w, [float]$h, [bool]$primary = $true) {
  $fill = if ($primary) { $palette.Dark } else { $palette.Lilac }
  $ink = if ($primary) { $palette.Paper } else { $palette.Ink }
  Fill-RoundRect $g $fill $x $y $w $h 10
  if ($primary) { Fill-RoundRect $g ([System.Drawing.ColorTranslator]::FromHtml('#352132')) $x ($y + $h - 5) $w 5 3 }
  Draw-Text $g $text $x ($y + (($h - 22) / 2)) $w 28 15 $ink 'Segoe UI' ([System.Drawing.FontStyle]::Bold) 'Center'
}

function Draw-Cursor($g, [float]$x, [float]$y, [bool]$click = $false) {
  if ($click) {
    $ring = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(150, $palette.Berry), 4)
    $g.DrawEllipse($ring, $x - 17, $y - 17, 34, 34)
    $ring.Dispose()
  }
  $points = [System.Drawing.PointF[]]@(
    [System.Drawing.PointF]::new([float]$x, [float]$y),
    [System.Drawing.PointF]::new([float]($x + 3), [float]($y + 28)),
    [System.Drawing.PointF]::new([float]($x + 10), [float]($y + 20)),
    [System.Drawing.PointF]::new([float]($x + 17), [float]($y + 34)),
    [System.Drawing.PointF]::new([float]($x + 23), [float]($y + 31)),
    [System.Drawing.PointF]::new([float]($x + 16), [float]($y + 17)),
    [System.Drawing.PointF]::new([float]($x + 28), [float]($y + 15))
  )
  $brush = New-Brush $palette.Surface
  $pen = New-Object System.Drawing.Pen($palette.Ink, 2)
  $g.FillPolygon($brush, $points); $g.DrawPolygon($pen, $points)
  $pen.Dispose(); $brush.Dispose()
}

function Draw-Brand($g, [float]$x, [float]$y, [System.Drawing.Color]$color) {
  Draw-Text $g 'later' $x $y 220 70 55 $color 'Georgia' ([System.Drawing.FontStyle]::Bold)
  Draw-Text $g '*' ($x + 126) ($y + 5) 45 50 32 $palette.Citrus 'Georgia' ([System.Drawing.FontStyle]::Bold)
}

function Draw-Sloth($g, [float]$cx, [float]$cy, [float]$scale, [float]$gazeX = 0, [float]$gazeY = 0) {
  $bodyBrush = New-Brush ([System.Drawing.ColorTranslator]::FromHtml('#bf8eaa'))
  $shadowBrush = New-Brush ([System.Drawing.Color]::FromArgb(25, $palette.Dark))
  $faceBrush = New-Brush ([System.Drawing.ColorTranslator]::FromHtml('#f8dfcb'))
  $eyeBrush = New-Brush ([System.Drawing.ColorTranslator]::FromHtml('#94647f'))
  $whiteBrush = New-Brush $palette.White
  $inkBrush = New-Brush $palette.Ink
  $g.FillEllipse($shadowBrush, $cx - 86*$scale, $cy + 80*$scale, 172*$scale, 26*$scale)
  $g.FillEllipse($bodyBrush, $cx - 78*$scale, $cy - 82*$scale, 156*$scale, 178*$scale)
  $g.FillEllipse($faceBrush, $cx - 62*$scale, $cy - 61*$scale, 124*$scale, 108*$scale)
  foreach ($ex in @(-32, 32)) {
    $g.FillEllipse($eyeBrush, $cx + ($ex - 19)*$scale, $cy - 43*$scale, 38*$scale, 48*$scale)
    $g.FillEllipse($whiteBrush, $cx + ($ex - 13)*$scale, $cy - 35*$scale, 26*$scale, 29*$scale)
    $g.FillEllipse($inkBrush, $cx + ($ex - 6 + $gazeX)*$scale, $cy + (-27 + $gazeY)*$scale, 12*$scale, 14*$scale)
  }
  $g.FillEllipse($inkBrush, $cx - 8*$scale, $cy + 1*$scale, 16*$scale, 10*$scale)
  $smilePen = New-Object System.Drawing.Pen($palette.Dark, (2*$scale))
  $g.DrawArc($smilePen, $cx - 16*$scale, $cy + 9*$scale, 32*$scale, 19*$scale, 10, 160)
  $smilePen.Dispose()
  $inkBrush.Dispose(); $whiteBrush.Dispose(); $eyeBrush.Dispose(); $faceBrush.Dispose(); $shadowBrush.Dispose(); $bodyBrush.Dispose()
}

function Draw-Sidebar($g, [int]$active = 0, [int]$done = 0) {
  $dark = New-Brush $palette.Dark
  $g.FillRectangle($dark, 0, 0, 238, 720); $dark.Dispose()
  Draw-Brand $g 30 29 $palette.Paper
  $items = @(
    @('THE UNLOADING ZONE', 140),
    @("OFF YOUR PLATE    $done", 194),
    @('UNDER THE HOOD', 248)
  )
  for ($i = 0; $i -lt $items.Count; $i++) {
    if ($i -eq $active) { Fill-RoundRect $g $palette.Citrus 22 ($items[$i][1] - 11) 194 43 9 }
    $c = if ($i -eq $active) { $palette.Ink } else { $palette.Paper }
    Draw-Text $g ([string]$items[$i][0]) 41 ([float]$items[$i][1]) 170 25 11 $c 'Segoe UI' ([System.Drawing.FontStyle]::Bold)
  }
  $linePen = New-Object System.Drawing.Pen([System.Drawing.ColorTranslator]::FromHtml('#7a596e'), 1)
  $g.DrawLine($linePen, 22, 616, 216, 616); $linePen.Dispose()
  Fill-RoundRect $g ([System.Drawing.ColorTranslator]::FromHtml('#704d69')) 26 635 44 44 13
  Stroke-RoundRect $g $palette.Citrus 2 26 635 44 44 13
  Draw-Text $g 'YU' 26 648 44 22 12 $palette.Paper 'Segoe UI' ([System.Drawing.FontStyle]::Bold) 'Center'
  Draw-Text $g 'LOCAL ACCOUNT' 82 637 123 17 8 ([System.Drawing.ColorTranslator]::FromHtml('#d6b7ca')) 'Segoe UI' ([System.Drawing.FontStyle]::Bold)
  Draw-Text $g 'Your username' 82 653 130 20 12 $palette.Paper 'Segoe UI' ([System.Drawing.FontStyle]::Bold)
  Draw-Text $g 'Saved on this device' 82 672 130 18 10 ([System.Drawing.ColorTranslator]::FromHtml('#c9aabd'))
}

function Draw-FrameBase($g, [int]$scene, [float]$p) {
  $paperBrush = New-Brush $palette.Paper
  $g.FillRectangle($paperBrush, 0, 0, 1280, 720); $paperBrush.Dispose()
  $lift = [Math]::Round((1 - $p) * 20)
  switch ($scene) {
    0 {
      Draw-Pill $g 'OPEN-SOURCE AI  /  PRIVATE BY DEFAULT' 420 (88 + $lift) 440 $palette.Lilac $palette.Berry
      Draw-Brand $g 488 (171 + $lift) $palette.Ink
      Draw-Text $g 'Do less. Keep more headspace.' 245 (274 + $lift) 790 74 54 $palette.Ink 'Georgia' ([System.Drawing.FontStyle]::Regular) 'Center'
      Draw-Text $g 'A local AI assistant that turns messy thoughts into useful next steps.' 290 (365 + $lift) 700 55 21 $palette.Muted 'Segoe UI' ([System.Drawing.FontStyle]::Regular) 'Center'
      Draw-Sloth $g 640 (532 + $lift) 0.65 ([Math]::Sin($p*6)*3) 1
      Draw-Text $g 'WALKTHROUGH  -  25 SECONDS' 470 665 340 22 11 $palette.Berry 'Segoe UI' ([System.Drawing.FontStyle]::Bold) 'Center'
    }
    1 {
      Draw-Sidebar $g 0 0
      Draw-Text $g 'LESS HUSTLE, MORE HUMAN' 286 (35 + $lift) 350 24 11 $palette.Berry 'Segoe UI' ([System.Drawing.FontStyle]::Bold)
      Draw-Text $g 'Leave it for later.' 286 (70 + $lift) 550 75 55 $palette.Ink 'Georgia'
      Draw-Text $g 'Drop every unfinished thought here. Messy is welcome.' 289 (142 + $lift) 610 40 18 $palette.Muted
      Fill-RoundRect $g $palette.Surface 286 (203 + $lift) 645 420 15
      Stroke-RoundRect $g $palette.Line 1 286 (203 + $lift) 645 420 15
      Draw-Text $g '01 / THE BRAIN DUMP' 316 (230 + $lift) 220 24 10 $palette.Muted 'Segoe UI' ([System.Drawing.FontStyle]::Bold)
      Draw-Text $g "What's sitting on your mind?" 316 (268 + $lift) 500 35 26 $palette.Ink 'Georgia'
      Fill-RoundRect $g ([System.Drawing.ColorTranslator]::FromHtml('#f9ece8')) 316 (319 + $lift) 585 153 9
      $typed = 'kal client ko reply karna hai, groceries bhi lena, aur Friday ka reminder set kar do'
      $count = [Math]::Min($typed.Length, [Math]::Floor($typed.Length * [Math]::Min(1, $p * 1.35)))
      Draw-Text $g $typed.Substring(0, $count) 339 (343 + $lift) 540 100 17 $palette.Ink
      Draw-Pill $g 'BARE MINIMUM' 316 (497 + $lift) 128 $palette.Lilac $palette.Muted
      Draw-Pill $g 'A LITTLE BIT' 452 (497 + $lift) 118 $palette.Citrus $palette.Ink
      Draw-Pill $g "LET'S DO THIS" 578 (497 + $lift) 127 $palette.Lilac $palette.Muted
      Draw-Button $g 'TAKE THIS OFF MY MIND  ->' 653 (559 + $lift) 248 53 $true
      Fill-RoundRect $g $palette.Peach 960 (203 + $lift) 275 420 15
      Draw-Text $g 'THE ART OF DOING LESS' 990 (231 + $lift) 220 22 10 ([System.Drawing.ColorTranslator]::FromHtml('#704859')) 'Segoe UI' ([System.Drawing.FontStyle]::Bold)
      Draw-Text $g "A little handoff.`nA lot of headspace." 990 (271 + $lift) 218 90 29 $palette.Ink 'Georgia'
      $steps = @('1   Let it all out','2   We get a head start','3   One tiny next move')
      for ($i=0; $i -lt 3; $i++) { Draw-Text $g $steps[$i] 990 (390 + $i*59 + $lift) 218 34 15 $palette.Ink 'Segoe UI' ([System.Drawing.FontStyle]::Bold) }
      Draw-Text $g 'HINGLISH IN. CLEAR ENGLISH OUT.' 316 662 600 26 13 $palette.Berry 'Segoe UI' ([System.Drawing.FontStyle]::Bold)
      Draw-Cursor $g (348 + 468*$p) (390 + 185*$p) ($p -gt .88)
    }
    2 {
      Draw-Sidebar $g 0 0
      Draw-Text $g 'THE HANDOFF' 286 (40 + $lift) 350 24 11 $palette.Berry 'Segoe UI' ([System.Drawing.FontStyle]::Bold)
      Draw-Text $g 'Choose your energy. Later does the first bit.' 286 (76 + $lift) 930 60 41 $palette.Ink 'Georgia'
      Fill-RoundRect $g $palette.Surface 286 (168 + $lift) 949 445 16
      Stroke-RoundRect $g $palette.Line 1 286 (168 + $lift) 949 445 16
      Draw-Text $g 'YOUR ENERGY TODAY' 326 (208 + $lift) 220 22 11 $palette.Muted 'Segoe UI' ([System.Drawing.FontStyle]::Bold)
      Draw-Pill $g '5 MIN  /  BARE MINIMUM' 326 (249 + $lift) 220 $palette.Lilac $palette.Muted
      Draw-Pill $g '15 MIN  /  A LITTLE BIT' 560 (249 + $lift) 225 $palette.Citrus $palette.Ink
      Draw-Pill $g '60 MIN  /  LET US DO THIS' 799 (249 + $lift) 242 $palette.Lilac $palette.Muted
      Draw-Text $g 'Later extracts obligations, keeps evidence, and drafts only what fits your energy.' 326 (330 + $lift) 840 66 22 $palette.Muted
      Draw-Button $g 'TAKE THIS OFF MY MIND  ->' 698 (437 + $lift) 300 66 $true
      Fill-RoundRect $g $palette.Lilac 326 (535 + $lift) 675 45 10
      $barW = [Math]::Max(14, 675 * [Math]::Min(1, $p * 1.35))
      Fill-RoundRect $g $palette.Berry 326 (535 + $lift) $barW 45 10
      Draw-Text $g 'LOCAL QWEN MODEL  -  NO PAID API' 326 (548 + $lift) 675 22 12 $palette.Paper 'Segoe UI' ([System.Drawing.FontStyle]::Bold) 'Center'
      Draw-Cursor $g (650 + 220*$p) (445 + 31*$p) ($p -gt .48 -and $p -lt .68)
      Draw-Text $g 'A smaller workload means a calmer, more realistic next move.' 364 645 790 40 17 $palette.Berry 'Segoe UI' ([System.Drawing.FontStyle]::Bold) 'Center'
    }
    3 {
      Draw-Sidebar $g 0 0
      Draw-Text $g 'A LITTLE PROGRESS COUNTS' 286 (34 + $lift) 420 24 11 $palette.Berry 'Segoe UI' ([System.Drawing.FontStyle]::Bold)
      Draw-Text $g 'Your next small moves' 286 (70 + $lift) 700 60 46 $palette.Ink 'Georgia'
      Draw-Pill $g '3 READY' 858 (83 + $lift) 112 $palette.Citrus $palette.Ink
      $cards = @(
        @('REPLY', 'Reply to the client', 'A polished English draft from your Hinglish note.', 'OPEN DRAFT'),
        @('CHECKLIST', 'Pick up groceries', 'A short list with the smallest useful next step.', 'VIEW LIST'),
        @('CALENDAR', 'Friday reminder', 'Review a ready-to-import calendar event.', 'REVIEW EVENT')
      )
      for ($i=0; $i -lt 3; $i++) {
        $cardY = 163 + $i*151 + $lift + [Math]::Max(0, (1-$p)*40 - $i*6)
        Fill-RoundRect $g $palette.Surface 286 $cardY 949 128 14
        Stroke-RoundRect $g $palette.Line 1 286 $cardY 949 128 14
        Fill-RoundRect $g $palette.Lilac 310 ($cardY + 25) 78 78 13
        Draw-Text $g ([string]($i+1)) 310 ($cardY + 42) 78 44 30 $palette.Berry 'Georgia' ([System.Drawing.FontStyle]::Bold) 'Center'
        Draw-Text $g $cards[$i][0] 416 ($cardY + 19) 200 22 10 $palette.Berry 'Segoe UI' ([System.Drawing.FontStyle]::Bold)
        Draw-Text $g $cards[$i][1] 416 ($cardY + 43) 475 32 24 $palette.Ink 'Georgia'
        Draw-Text $g $cards[$i][2] 416 ($cardY + 79) 520 25 14 $palette.Muted
        Draw-Button $g $cards[$i][3] 1025 ($cardY + 40) 172 48 ($i -eq 0)
      }
      Draw-Text $g 'Every card is editable. Later never sends or schedules anything without you.' 335 651 850 30 15 $palette.Muted 'Segoe UI' ([System.Drawing.FontStyle]::Regular) 'Center'
      Draw-Cursor $g (1085 + 10*[Math]::Sin($p*6)) (227 + 302*$p) ($p -gt .9)
    }
    4 {
      Draw-Sidebar $g 1 3
      Draw-Text $g 'LOOK AT YOU GO' 286 (55 + $lift) 420 24 11 $palette.Berry 'Segoe UI' ([System.Drawing.FontStyle]::Bold)
      Draw-Text $g 'Off your plate.' 286 (92 + $lift) 700 70 55 $palette.Ink 'Georgia'
      Draw-Text $g 'Finished items stay in this browser so the little wins are easy to revisit.' 290 (168 + $lift) 790 46 18 $palette.Muted
      $doneItems = @('Client reply reviewed','Groceries checklist finished','Friday reminder exported')
      for($i=0; $i -lt 3; $i++) {
        $y = 247 + $i*110 + $lift
        Fill-RoundRect $g $palette.Surface 286 $y 800 86 13
        Stroke-RoundRect $g $palette.Line 1 286 $y 800 86 13
        Fill-RoundRect $g $palette.Citrus 312 ($y+20) 46 46 23
        Draw-Text $g 'OK' 312 ($y+31) 46 24 11 $palette.Ink 'Segoe UI' ([System.Drawing.FontStyle]::Bold) 'Center'
        Draw-Text $g $doneItems[$i] 384 ($y+23) 520 33 22 $palette.Ink 'Georgia'
        Draw-Text $g 'COMPLETED LOCALLY' 384 ($y+56) 230 18 10 $palette.Berry 'Segoe UI' ([System.Drawing.FontStyle]::Bold)
      }
      Draw-Text $g 'DONE COUNT: 3' 1115 269 105 160 13 $palette.Berry 'Segoe UI' ([System.Drawing.FontStyle]::Bold) 'Center'
      Draw-Text $g 'Less guilt. More room to breathe.' 286 624 850 40 26 $palette.Ink 'Georgia' ([System.Drawing.FontStyle]::Italic) 'Center'
      Draw-Cursor $g 119 215 ($p -gt .62 -and $p -lt .82)
    }
    5 {
      Draw-Sidebar $g 2 3
      Draw-Text $g 'OPEN BY DESIGN' 286 (42 + $lift) 420 24 11 $palette.Berry 'Segoe UI' ([System.Drawing.FontStyle]::Bold)
      Draw-Text $g 'Small model. Personal superpower.' 286 (80 + $lift) 850 70 48 $palette.Ink 'Georgia'
      $nodes = @(
        @{x=300; y=230; w=245; title='YOUR BROWSER'; sub='Notes + drafts stay close'; fill=$palette.Surface},
        @{x=637; y=230; w=245; title='LOCAL SERVER'; sub='Validated structured output'; fill=$palette.Peach},
        @{x=974; y=230; w=245; title='OLLAMA'; sub='Qwen open-weight model'; fill=$palette.Lilac}
      )
      foreach($n in $nodes) {
        Fill-RoundRect $g $n.fill $n.x ($n.y+$lift) $n.w 170 18
        Stroke-RoundRect $g $palette.Line 1 $n.x ($n.y+$lift) $n.w 170 18
        Draw-Text $g $n.title $n.x ($n.y+36+$lift) $n.w 26 13 $palette.Berry 'Segoe UI' ([System.Drawing.FontStyle]::Bold) 'Center'
        Draw-Text $g $n.sub ($n.x+20) ($n.y+83+$lift) ($n.w-40) 55 18 $palette.Ink 'Georgia' ([System.Drawing.FontStyle]::Regular) 'Center'
      }
      $arrowPen = New-Object System.Drawing.Pen($palette.Berry, 5)
      $arrowPen.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor
      $g.DrawLine($arrowPen, 555, 315+$lift, 625, 315+$lift)
      $g.DrawLine($arrowPen, 892, 315+$lift, 962, 315+$lift)
      $arrowPen.Dispose()
      Draw-Pill $g 'WORKS OFFLINE AFTER MODEL DOWNLOAD' 355 (470+$lift) 320 $palette.Citrus $palette.Ink
      Draw-Pill $g 'SWAP THE MODEL' 694 (470+$lift) 188 $palette.Lilac $palette.Ink
      Draw-Pill $g 'NO PAID INFERENCE API' 901 (470+$lift) 260 $palette.Peach $palette.Ink
      Draw-Text $g 'Open innovation matters because privacy, behavior, and cost remain under your control.' 330 570 850 72 24 $palette.Ink 'Georgia' ([System.Drawing.FontStyle]::Italic) 'Center'
      Draw-Cursor $g (107 + 15*$p) (269 + 15*$p) ($p -gt .2 -and $p -lt .35)
    }
    6 {
      Draw-Pill $g 'READY FOR GITHUB + RENDER' 455 (89 + $lift) 370 $palette.Citrus $palette.Ink
      Draw-Text $g "A lazy assistant.`nA serious portfolio project." 230 (170 + $lift) 820 145 55 $palette.Ink 'Georgia' ([System.Drawing.FontStyle]::Regular) 'Center'
      Draw-Text $g 'Open-source AI  /  Ollama  /  Node.js  /  Docker  /  Local-first UX' 260 (350 + $lift) 760 42 18 $palette.Berry 'Segoe UI' ([System.Drawing.FontStyle]::Bold) 'Center'
      Draw-Button $g 'github.com/swapnil-coder5/Later' 406 (432 + $lift) 468 62 $true
      Draw-Sloth $g 640 (602 + $lift) 0.46 ([Math]::Sin($p*7)*4) 0
      Draw-Text $g 'BUILT FOR THE THINGS YOU KEEP MEANING TO DO.' 370 672 540 23 12 $palette.Muted 'Segoe UI' ([System.Drawing.FontStyle]::Bold) 'Center'
      Draw-Cursor $g (845 - 190*$p) (470 + 2*[Math]::Sin($p*8)) ($p -gt .75)
    }
  }
}

$sceneSeconds = 3.6
$sceneCount = 7
$totalFrames = [int]($sceneSeconds * $sceneCount * $Fps)
$playlistPath = Join-Path (Split-Path $OutputDir -Parent) 'frames.m3u8'
$playlist = New-Object System.Collections.Generic.List[string]
$playlist.Add('#EXTM3U')

for ($frame = 0; $frame -lt $totalFrames; $frame++) {
  $seconds = $frame / $Fps
  $scene = [Math]::Min($sceneCount - 1, [Math]::Floor($seconds / $sceneSeconds))
  $local = ($seconds - ($scene * $sceneSeconds)) / $sceneSeconds
  $ease = 1 - [Math]::Pow(1 - [Math]::Min(1, $local * 2.2), 3)

  $bmp = New-Object System.Drawing.Bitmap($Width, $Height, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
  $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  Draw-FrameBase $g $scene $ease

  $fadeAlpha = 0
  if ($local -lt 0.12) { $fadeAlpha = [int](255 * (1 - ($local / 0.12))) }
  elseif ($local -gt 0.91) { $fadeAlpha = [int](255 * (($local - 0.91) / 0.09)) }
  if ($fadeAlpha -gt 0) {
    $fadeBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb([Math]::Min(255,$fadeAlpha), $palette.Paper))
    $g.FillRectangle($fadeBrush, 0, 0, $Width, $Height); $fadeBrush.Dispose()
  }

  $progressBrush = New-Brush ([System.Drawing.Color]::FromArgb(100, $palette.Berry))
  $g.FillRectangle($progressBrush, 0, $Height-4, [int]($Width * (($frame+1)/$totalFrames)), 4)
  $progressBrush.Dispose()

  $file = Join-Path $OutputDir ('frame-{0:D4}.png' -f $frame)
  $bmp.Save($file, [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose(); $bmp.Dispose()
  $playlist.Add($file)
}

[System.IO.File]::WriteAllLines($playlistPath, $playlist, (New-Object System.Text.UTF8Encoding($false)))
Write-Output "Rendered $totalFrames frames to $OutputDir"
Write-Output "Playlist: $playlistPath"
