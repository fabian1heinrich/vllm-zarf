# vLLM ZARF

Zarf package to deploy vLLM on Kubernetes with a bundled local model image.

## What is included

- `Deployment` + `Service` for vLLM on port `8000`
- Bundled model artifacts mounted from an OCI `image` volume

## Build model image (model artifacts only)

The `Dockerfile` uses a multi-stage build:

1. Pulls a model from Hugging Face in a build stage
2. Copies only `/models` into a `scratch` final image

Build and push the model image referenced in `zarf.yaml`:

```bash
docker build -t localhost:5000/vllm/qwen:2.5-0.5b-instruct --build-arg MODEL=Qwen/Qwen2.5-0.5B-Instruct .
docker push localhost:5000/vllm/qwen:2.5-0.5b-instruct
```

If the model requires auth, add `--build-arg HF_TOKEN=$HF_TOKEN`.

The deployment mounts the model image at `/models`, which is used by vLLM at startup.

## Build package

```bash
zarf package create
```

## Deploy package

```bash
zarf package deploy zarf-package-vllm-*.tar.zst
```
