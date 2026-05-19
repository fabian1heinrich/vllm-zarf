# syntax=docker/dockerfile:1.7

ARG VLLM_IMAGE=docker.io/vllm/vllm-openai-cpu:latest
ARG MODEL=Qwen/Qwen2.5-0.5B-Instruct

FROM ${VLLM_IMAGE} AS downloader

ARG MODEL

ENV HF_HUB_DISABLE_TELEMETRY=1

RUN set -eux; \
    python3 -m pip install --no-cache-dir --upgrade huggingface_hub; \
    export MODEL; \
    python3 - <<'PY'
import os
from pathlib import Path

from huggingface_hub import snapshot_download

model = os.environ["MODEL"]
model_dir_name = model.split("/", 1)[1] if "/" in model else model
local_dir = Path("/models") / model_dir_name
local_dir.mkdir(parents=True, exist_ok=True)

download_kwargs = {"repo_id": model, "local_dir": str(local_dir)}

try:
    snapshot_download(local_dir_use_symlinks=False, **download_kwargs)
except TypeError:
    snapshot_download(**download_kwargs)
PY

FROM scratch

# Final image is model artifacts only (no vLLM base image filesystem).
# Copy model directories to image root so a Kubernetes image volume mounted
# at /models exposes files at /models/<model-dir>/...
COPY --from=downloader /models/ /
