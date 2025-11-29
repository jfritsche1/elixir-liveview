#!/bin/bash

# AirGap App Setup Script
# This script sets up the Phoenix application with minimal dependencies

echo "==================================="
echo "AirGap Map System - Setup Script"
echo "==================================="

# Check for required tools
check_requirement() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ $1 is not installed. Please install it first."
        exit 1
    else
        echo "✅ $1 is installed"
    fi
}

echo ""
echo "Checking requirements..."
check_requirement "elixir"
check_requirement "mix"
check_requirement "node"
check_requirement "npm"

# Optional but recommended
if command -v nats-server &> /dev/null; then
    echo "✅ nats-server is installed"
else
    echo "⚠️  nats-server is not installed (optional but recommended)"
fi

if command -v protoc &> /dev/null; then
    echo "✅ protoc is installed"
else
    echo "⚠️  protoc is not installed (needed for Proto compilation)"
fi

echo ""
echo "Installing dependencies..."
mix deps.get

echo ""
echo "Setting up assets..."
mix assets.setup

echo ""
echo "Downloading Leaflet for offline use..."
./scripts/download_leaflet.sh

echo ""
echo "Compiling Proto files (if protoc is available)..."
if command -v protoc &> /dev/null; then
    protoc --elixir_out=./lib/airgap_app/proto priv/proto/messages.proto
else
    echo "Skipping Proto compilation (protoc not found)"
fi

echo ""
echo "Creating database of tiles directory..."
mkdir -p priv/static/tiles

echo ""
echo "==================================="
echo "Setup complete!"
echo "==================================="
echo ""
echo "Next steps:"
echo "1. Start NATS server (if installed): nats-server"
echo "2. Start Phoenix server: mix phx.server"
echo "3. Visit http://localhost:4000"
echo ""
echo "For offline maps, run: ./scripts/download_tiles.sh"
echo ""
echo "To test with sample data, run in IEx:"
echo "  iex -S mix"
echo "  AirgapApp.TestHelper.send_multiple_updates(20)"
echo ""
