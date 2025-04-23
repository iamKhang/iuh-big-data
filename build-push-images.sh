#!/bin/bash

# Set the registry address to the manager node's IP
REGISTRY=192.168.19.10:5000

# Make sure the registry is running
if ! docker ps | grep -q registry; then
  echo "Starting Docker registry..."
  docker run -d -p 5000:5000 --restart=always --name registry registry:2
else
  echo "Docker registry is already running."
fi

# Build and push the images
echo "Building and pushing images to $REGISTRY..."

# Build and push rng
echo "Building and pushing rng..."
docker build -t $REGISTRY/dockercoins_rng:latest ./rng
docker push $REGISTRY/dockercoins_rng:latest

# Build and push hasher
echo "Building and pushing hasher..."
docker build -t $REGISTRY/dockercoins_hasher:latest ./hasher
docker push $REGISTRY/dockercoins_hasher:latest

# Build and push webui
echo "Building and pushing webui..."
docker build -t $REGISTRY/dockercoins_webui:latest ./webui
docker push $REGISTRY/dockercoins_webui:latest

# Build and push worker
echo "Building and pushing worker..."
docker build -t $REGISTRY/dockercoins_worker:latest ./worker
docker push $REGISTRY/dockercoins_worker:latest

echo "All images built and pushed to $REGISTRY"
echo "You can now deploy the stack with: ./deploy-stack.sh"
