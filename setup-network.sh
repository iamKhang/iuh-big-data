#!/bin/bash

# Create the Docker network if it doesn't exist
if ! docker network ls | grep -q hoangkhang-net; then
  echo "Creating hoangkhang-net network..."
  docker network create --driver overlay --attachable hoangkhang-net
else
  echo "Network hoangkhang-net already exists."
fi

echo "Network setup complete!"
