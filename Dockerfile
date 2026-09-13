# syntax=docker/dockerfile:1.7

ARG VLLM_IMAGE=docker.io/vllm/vllm-openai-cpu:v0.29.0-x86_64@sha256:66064cf683152e60eff2e5b18ec2d4ace236fb063c0a241f918691db9caddcf4
ARG MODEL=Qwen/Qwen2.5-7B-Instruct
ARG MODEL_REVISION=a09a35458c702b33eeacc393d103063234e8bc28

FROM ${VLLM_IMAGE} AS downloader

ARG MODEL
ARG MODEL_REVISION

ENV HF_HUB_DISABLE_TELEMETRY=1

RUN set -eux; \
    export MODEL MODEL_REVISION; \
    python3 - <<'PY'
import os
import shutil
from pathlib import Path

from huggingface_hub import snapshot_download

model = os.environ["MODEL"]
model_revision = os.environ["MODEL_REVISION"]
model_dir_name = model.split("/", 1)[1] if "/" in model else model
local_dir = Path("/models") / model_dir_name
local_dir.mkdir(parents=True, exist_ok=True)

download_kwargs = {
    "repo_id": model,
    "revision": model_revision,
    "local_dir": str(local_dir),
}

try:
    snapshot_download(local_dir_use_symlinks=False, **download_kwargs)
except TypeError:
    snapshot_download(**download_kwargs)

shutil.rmtree(local_dir / ".cache", ignore_errors=True)
PY

FROM scratch

# Final image is model artifacts only (no vLLM base image filesystem).
# Copy model directories to image root so a Kubernetes image volume mounted
# at /models exposes files at /models/<model-dir>/...
COPY --from=downloader /models/ /
