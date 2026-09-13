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

The 7B image uses upstream revision
`a09a35458c702b33eeacc393d103063234e8bc28` and is consumed by Linux/AMD64
deployments at child-manifest digest
`sha256:59b4a01d4e56f14b3997af400ed33c90d336a43f247aeb742637c3d02f304f1b`.

The deployment mounts the digest-pinned 7B model image at `/models`, enables
automatic tool choice with vLLM's Hermes parser, and serves the model as
`Qwen/Qwen2.5-7B-Instruct`. The package also carries the existing digest-pinned
0.5B artifact for smoke tests.

## Build package

```bash
zarf package create
```

## Deploy package

```bash
zarf package deploy zarf-package-vllm-*.tar.zst
```
