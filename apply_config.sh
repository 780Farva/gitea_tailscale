#! /usr/bin/env bash

set -e  # Exit immediately if any command fails

# Define variables
TS_CONFIG_DEST="/config/ts_config.json"
VOLUME_NAME="gitea_ts_gitea_config"

echo "🚀 Starting the Docker Compose environment..."
docker compose up -d ts-git

# Wait a few seconds to ensure volumes are created
sleep 5

echo "🔍 Checking if the Tailscale config volume is initialized..."
# Create a temporary container to access the volume
docker run --rm -v ${VOLUME_NAME}:/config alpine ls /config > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "⚠️  Volume ${VOLUME_NAME} not found. Creating it now..."
    docker volume create ${VOLUME_NAME}
fi

echo "📂 Copying ts_config.json into the Docker volume..."
docker run --rm -v ${VOLUME_NAME}:/config -v $(pwd):/host alpine cp /host/ts_config.json /config/

echo "✅ Configuration copied successfully!"

echo "🔄 Restarting Tailscale container to apply changes..."
docker compose up -d 

echo "🎉 Setup complete! Your environment is ready."
