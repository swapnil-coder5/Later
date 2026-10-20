FROM node:22-bookworm-slim AS node-runtime
FROM ollama/ollama:0.40.6

COPY --from=node-runtime /usr/local/ /usr/local/

WORKDIR /app
COPY package.json core.mjs server.mjs LICENSE ./
COPY public ./public
COPY scripts/render-start.sh ./scripts/render-start.sh

RUN chmod +x ./scripts/render-start.sh

ENV NODE_ENV=production \
    OLLAMA_HOST=127.0.0.1:11434 \
    OLLAMA_MODELS=/var/lib/ollama/models \
    OLLAMA_MODEL=qwen2.5:0.5b \
    OLLAMA_CONTEXT=4096 \
    OLLAMA_MAX_LOADED_MODELS=1 \
    OLLAMA_NUM_PARALLEL=1

EXPOSE 10000
ENTRYPOINT []
CMD ["/app/scripts/render-start.sh"]
