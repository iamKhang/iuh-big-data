#!/bin/bash

# This script configures Docker on all nodes to trust the insecure registry

# Set the registry address to the manager node's IP
REGISTRY_IP=192.168.19.10

echo "Setting up Docker to trust the insecure registry at $REGISTRY_IP:5000"

# Create or update the Docker daemon configuration
cat > /etc/docker/daemon.json <<EOF
{
  "insecure-registries": ["$REGISTRY_IP:5000"]
}
EOF

echo "Restarting Docker service..."
systemctl restart docker

echo "Docker configured to trust the insecure registry at $REGISTRY_IP:5000"
echo "Note: This script must be run on all nodes in the swarm with sudo privileges"
