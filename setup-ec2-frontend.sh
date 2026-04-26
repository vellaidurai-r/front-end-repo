#!/bin/bash

# EC2 t2.micro Setup Script for Multi-Environment Frontend
# This script sets up Docker containers for Dev, Staging, and Production

set -e

echo "🚀 EC2 t2.micro Setup for Frontend Environments"
echo "=============================================="
echo ""

# Update system
echo "📦 Updating system packages..."
sudo yum update -y
sudo yum install -y docker git

# Start Docker
echo "🐳 Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Add ec2-user to docker group
echo "👤 Adding docker permissions..."
sudo usermod -aG docker ec2-user
newgrp docker

# Pull and start frontend containers
echo "🌐 Setting up Frontend Environments..."

# Dev Environment (Port 3000)
echo "  Starting DEV environment on port 3000..."
docker run -d \
  --name frontend-dev \
  --restart always \
  -p 3000:3000 \
  -e VITE_ENVIRONMENT=development \
  -e VITE_BACKEND_URL=http://3.24.242.50:3000 \
  497162053399.dkr.ecr.ap-southeast-2.amazonaws.com/frontend-dev:latest || true

# Staging Environment (Port 3001)
echo "  Starting STAGING environment on port 3001..."
docker run -d \
  --name frontend-staging \
  --restart always \
  -p 3001:3000 \
  -e VITE_ENVIRONMENT=staging \
  -e VITE_BACKEND_URL=http://3.25.70.32:3000 \
  497162053399.dkr.ecr.ap-southeast-2.amazonaws.com/frontend-staging:latest || true

# Production Environment (Port 3002)
echo "  Starting PRODUCTION environment on port 3002..."
docker run -d \
  --name frontend-prod \
  --restart always \
  -p 3002:3000 \
  -e VITE_ENVIRONMENT=production \
  -e VITE_BACKEND_URL=http://16.176.7.157:3000 \
  497162053399.dkr.ecr.ap-southeast-2.amazonaws.com/frontend-prod:latest || true

echo ""
echo "✅ Setup Complete!"
echo ""
echo "🌐 Frontend URLs:"
echo "  Dev:        http://<EC2-IP>:3000"
echo "  Staging:    http://<EC2-IP>:3001"
echo "  Production: http://<EC2-IP>:3002"
echo ""
echo "🔑 Backend URLs:"
echo "  Dev:        http://3.24.242.50:3000"
echo "  Staging:    http://3.25.70.32:3000"
echo "  Production: http://16.176.7.157:3000"
echo ""
echo "📊 View running containers:"
echo "  docker ps"
echo ""
echo "📝 View container logs:"
echo "  docker logs frontend-dev"
echo "  docker logs frontend-staging"
echo "  docker logs frontend-prod"
