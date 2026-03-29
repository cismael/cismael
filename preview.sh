#!/bin/bash

# Define the local port to use for Grip
PORT=6419

# Get the absolute path to the current directory
PROJECT_DIR=$(cd "$(dirname "$0")" && pwd)

# Check if PROJECT_DIR is empty
if [ -z "$PROJECT_DIR" ]; then
    echo "❌ Error: Could not determine the project directory."
    exit 1
fi

# Load environment variables from .env file if it exists
if [ -f "$PROJECT_DIR/.env" ]; then
    echo "📁 Loading environment variables from .env file..."
    export $(cat "$PROJECT_DIR/.env" | grep -v '#' | xargs)
fi

# Check if GitHub credentials are set
if [ -z "$GITHUB_USER" ] || [ -z "$GITHUB_PASS" ]; then
    echo "❌ Error: GitHub credentials not set."
    echo "Please create a .env file in the project root with:"
    echo ""
    echo "  GITHUB_USER=your_github_username"
    echo "  GITHUB_PASS=your_github_personal_access_token"
    echo ""
    exit 1
fi

# Print instructions to the user
echo "--------------------------------------------------"
echo "🚀 Starting GitHub README Previewer (Grip)"
echo "--------------------------------------------------"
echo "Project Directory: $PROJECT_DIR"
echo "URL: http://localhost:$PORT"
echo "Press Ctrl+C to stop the server."
echo "--------------------------------------------------"

# Run the Grip server via Docker
# --rm: Automatically remove the container when stopped
# -v: Mount the project directory into the container
# -w: Set the working directory to /app
# -p: Map the container's port to the local host's port
# mbentley/grip: The official-ish Grip Docker image
# 0.0.0.0:$PORT: Start the server and listen on all interfaces (passed as argument to the "grip" entrypoint)
docker run --rm \
    --name github-readme-preview \
    -v "$PROJECT_DIR:/app" \
    -w /app \
    -p $PORT:$PORT \
    mbentley/grip \
    --user $GITHUB_USER \
    --pass $GITHUB_PASS \
    0.0.0.0:$PORT
