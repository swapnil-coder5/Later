#!/bin/sh
set -eu

mkdir -p "${OLLAMA_MODELS:-/var/lib/ollama/models}"
ollama serve &

(
  attempts=0
  until ollama list >/dev/null 2>&1; do
    attempts=$((attempts + 1))
    if [ "$attempts" -ge 60 ]; then
      echo "Ollama did not become ready; the sample workflows remain available." >&2
      exit 0
    fi
    sleep 1
  done

  model="${OLLAMA_MODEL:-qwen2.5:0.5b}"
  if ! ollama show "$model" >/dev/null 2>&1; then
    echo "Downloading open-weight model: $model"
    ollama pull "$model" || echo "Model download failed; Render will retry on the next restart." >&2
  fi
) &

exec node server.mjs
