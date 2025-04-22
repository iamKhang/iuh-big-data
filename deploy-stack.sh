#!/bin/bash

# Make sure the network exists
./setup-network.sh

# Deploy the stack
echo "Deploying the DockerCoins stack..."
docker stack deploy -c docker-stack.yml dockercoins

echo "Stack deployment initiated!"
echo "You can check the status with: docker stack services dockercoins"
