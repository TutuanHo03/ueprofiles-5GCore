# UEProfiles 5G Core Deployment on Kubernetes

## Overview

This document provides instructions for deploying the UEProfiles 5G Core web application on a Kubernetes cluster using Minikube. The application consists of three main components:

- **Frontend**: A React web application for user interaction
- **Backend**: An API service that handles business logic
- **MongoDB**: Database for storing UEProfiles data

The deployment uses Kubernetes resources to orchestrate these components and make them work together.

## Architecture

```
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│    Frontend     │──────▶     Backend     │──────▶     MongoDB     │
│   (React App)   │      │   (API Server)  │      │  (Database)     │
└─────────────────┘      └─────────────────┘      └─────────────────┘
        │                        │                        │
        └────────────────────────┼────────────────────────┘
                                 │
                                 ▼
                        Kubernetes Cluster
                        (Minikube)
```

## Prerequisites

- **Docker** - For building and running containers
- **Minikube** - Local Kubernetes cluster
- **kubectl** - Kubernetes command-line tool
- **Git** (optional) - To clone the repository

## Installation

### 1. Install Prerequisites

#### Docker

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

#### Minikube

```bash
# Linux
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb
```

#### kubectl

```bash
# Linux
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

# If the folder `/etc/apt/keyrings` does not exist, it should be created before the curl command, read the note below.
# sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring

# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctly

sudo apt-get update
sudo apt-get install -y kubectl
```

### 2. Clone the Repository

```bash
git clone <repository_url>
cd ueprofiles-5GCore
```

## Deployment

### Automated Deployment

You can deploy the entire application with a single script:

```bash
chmod +x k8s-script.sh
./k8s-script.sh
```

This script will:
1. Start Minikube if not already running
2. Enable the Ingress addon
3. Build Docker images for frontend and backend
4. Deploy all Kubernetes resources
5. Set up port forwarding to access the application

### Manual Deployment Steps

If you prefer to understand the deployment process step by step:

#### 1. Start Minikube

```bash
minikube start --driver=docker
```

#### 2. Enable Ingress Controller

```bash
minikube addons enable ingress
```

#### 3. Configure Docker to Use Minikube's Docker Daemon

```bash
eval $(minikube docker-env)
```

#### 4. Build Docker Images

Build backend:
```bash
docker build -t ueprofiles-5gcore-backend:latest ./backend-webUE
```

Build frontend:
```bash
cd ./frontend-webue
docker build --build-arg REACT_APP_API_URL=http://localhost:8080 -t ueprofiles-5gcore-frontend:latest .
cd ..
```

#### 5. Apply Kubernetes Configurations

```bash
# Create namespace and apply configurations
kubectl apply -f k8s/namespace.yml
kubectl apply -f k8s/configmap-secret.yml

# Deploy MongoDB
kubectl apply -f k8s/mongodb/

# Deploy backend
kubectl apply -f k8s/backend/

# Deploy frontend
kubectl apply -f k8s/frontend/
```

#### 6. Wait for Deployments

```bash
kubectl wait --namespace ueprofiles-5gcore --for=condition=available --timeout=300s deployment/mongodb
kubectl wait --namespace ueprofiles-5gcore --for=condition=available --timeout=300s deployment/backend
kubectl wait --namespace ueprofiles-5gcore --for=condition=available --timeout=300s deployment/frontend
```

#### 7. Set Up Port Forwarding

```bash
# Kill any existing port-forwarding processes
pkill -f "kubectl port-forward.*ueprofiles-5gcore" || true

# Start port-forwarding in background
kubectl port-forward -n ueprofiles-5gcore svc/backend 8080:8080 &
kubectl port-forward -n ueprofiles-5gcore svc/frontend 3000:3000 &
```

## Accessing the Application

After successful deployment, you can access the application at:

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080

## Directory Structure

The Kubernetes configuration files are organized as follows:

```
k8s/
├── namespace.yml              # Defines the ueprofiles-5gcore namespace
├── configmap-secret.yml       # ConfigMaps and Secrets for the application
├── mongodb/                   # MongoDB resources
│   ├── deployment.yaml        # MongoDB deployment
│   ├── pvc.yaml               # Persistent Volume Claim for MongoDB
│   └── service.yaml           # MongoDB service
├── backend/                   # Backend resources
│   ├── deployment.yaml        # Backend deployment
│   └── service.yaml           # Backend service
└── frontend/                  # Frontend resources
    ├── deployment.yaml        # Frontend deployment
    └── service.yaml           # Frontend service
```

## Troubleshooting

### Common Issues

#### Images Not Found

If pods fail to start with "ImagePullBackOff" or "ErrImageNot", check:

```bash
docker images | grep ueprofiles-5gcore

eval $(minikube docker-env)
```

#### Port Forwarding Issues

If you can't access the services:

```bash
# Check if port forwarding is active
ps aux | grep "kubectl port-forward"

# Restart port forwarding
kubectl port-forward -n ueprofiles-5gcore svc/backend 8080:8080 &
kubectl port-forward -n ueprofiles-5gcore svc/frontend 3000:3000 &
```

#### Pods Not Starting

Check pod status and logs:

```bash
kubectl get pods -n ueprofiles-5gcore
kubectl describe pod <pod-name> -n ueprofiles-5gcore
kubectl logs <pod-name> -n ueprofiles-5gcore
```

## Cleanup

To delete all deployed resources:

```bash
# Delete port forwarding processes
pkill -f "kubectl port-forward.*ueprofiles-5gcore" || true

# Delete all resources in the namespace
kubectl delete namespace ueprofiles-5gcore

# Stop Minikube (optional)
minikube stop
```

