# vLLM ZARF

Zarf package to deploy vLLM on Kubernetes with a bundled model image.

## What is included

- `Deployment` + `Service` for vLLM on port `8000`
- Bundled model artifacts mounted from an OCI `image` volume

## Build model image (model artifacts only)

The `Dockerfile` uses a multi-stage build:

1. Pulls a model from Hugging Face in a build stage
2. Copies only `/models` into a `scratch` final image

The GitHub Actions workflow publishes revision-pinned model images to GHCR.
Qwen2.5 7B is the default; the workflow-dispatch selector can republish the
smaller smoke-test model when needed:

```bash
ghcr.io/fabian1heinrich/vllm-zarf/qwen:2.5-7b-instruct
ghcr.io/fabian1heinrich/vllm-zarf/qwen:2.5-0.5b-instruct
```

The pinned Hugging Face revisions are resolved in
`.github/workflows/publish-model-image.yml`. The Dockerfile copies only the
selected model snapshot into the final `scratch` image.

The deployment mounts the model image at `/models`, which is used by vLLM at startup.

## Build package

```bash
zarf package create
```

## Deploy package

```bash
zarf package deploy zarf-package-vllm-*.tar.zst
```
