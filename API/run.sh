#!/bin/bash
cd App

# Define your Uvicorn app name, host, and port
APP_NAME="app.main"
HOST="0.0.0.0"
PORT="8000"

# Find the PID of the existing Uvicorn process
EXISTING_PID=$(pgrep -f "$APP_NAME")

if [ -n "$EXISTING_PID" ]; then
    echo "Stopping existing Uvicorn process (PID: $EXISTING_PID)..."
    kill -SIGINT "$EXISTING_PID"
    sleep 2  # Wait for graceful shutdown (optional)
fi

# Start the new Uvicorn process
echo "Starting new Uvicorn process..."
pipenv run uvicorn "$APP_NAME:app" --host "$HOST" --port "$PORT" > stdout.log 2> stderr.log &

echo "Uvicorn started successfully!"
