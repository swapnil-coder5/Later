# Contributing to Later

Thanks for improving Later. Keep changes small, reviewable, and consistent with its local-first scope.

## Development

1. Install Node.js 22 or newer.
2. Fork and clone the repository.
3. Run `npm start` and open `http://localhost:4173`.
4. Use the sample workflows when Ollama is unavailable.
5. Run `npm run check` before opening a pull request.

No dependency installation is currently required.

## Pull requests

- Explain the user-facing problem and resulting behavior.
- Include screenshots for visual changes.
- Add focused tests when changing validation or calendar serialization.
- Keep model output behind the existing review step.
- Do not add telemetry, cloud inference, or automatic external actions without discussing the change first.
- Never commit notes, exported notebooks, profile pictures, model files, or credentials.

## Reporting bugs

Include the operating system, Node version, Ollama version, model name, reproduction steps, expected behavior, and actual behavior. Remove personal text from screenshots and logs.
