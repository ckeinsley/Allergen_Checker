#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

# Define your Uvicorn app name, host, and port
APP_NAME="app.main"
HOST="0.0.0.0"
PORT="8000"

# Find the PID of the existing Uvicorn process
EXISTING_PID=$(pgrep -f "$APP_NAME:app" || true)

if [ -n "${EXISTING_PID}" ]; then
        echo "Stopping existing Uvicorn process (PID: ${EXISTING_PID})..."
        kill -SIGINT "${EXISTING_PID}"
        sleep 2  # Wait for graceful shutdown (optional)
fi

# Start the new Uvicorn process with uv, pointing PYTHONPATH at src/
echo "Starting new Uvicorn process via uv..."
# Load env vars from the repo root .env (so they're available before app import)
ENV_FILE="../.env"
PYTHONPATH="$(pwd)/src" \
    uv run --python 3.12 --with uvicorn "uvicorn" "${APP_NAME}:app" \
    --env-file "${ENV_FILE}" --host "${HOST}" --port "${PORT}" \
    > src/app/stdout.log 2> src/app/stderr.log &

echo "Uvicorn started successfully!"