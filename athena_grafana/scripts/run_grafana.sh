#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"

CONTAINER_NAME="${GRAFANA_CONTAINER_NAME:-grafana-athena}"
IMAGE="${GRAFANA_IMAGE:-grafana/grafana-oss:latest}"
PORT="${GRAFANA_PORT:-3000}"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing ${ENV_FILE}. Create it from ${ROOT_DIR}/.env.example."
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "docker not found in PATH."
  exit 1
fi

echo "Starting Grafana (${CONTAINER_NAME}) on http://localhost:${PORT}"

docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true

docker run -d --name "${CONTAINER_NAME}" \
  -p "${PORT}:3000" \
  --env-file "${ENV_FILE}" \
  -e "GF_INSTALL_PLUGINS=grafana-athena-datasource" \
  -v "${ROOT_DIR}/grafana/provisioning:/etc/grafana/provisioning" \
  "${IMAGE}" >/dev/null

echo "Tailing logs (Ctrl+C to stop tail; container keeps running)..."
docker logs -f --tail 200 "${CONTAINER_NAME}"

