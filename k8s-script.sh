#!/bin/bash

# Start minikube if not running
minikube status || minikube start --driver=docker

# Enable ingress addon
minikube addons enable ingress

# Đợi ingress controller khởi động
echo "Waiting ingress controller starting..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# Build Docker images using Minikube's Docker daemon
eval $(minikube docker-env)

# Build backend image
echo "Building backend image..."
docker build -t ueprofiles-5gcore-backend:latest ./backend-webUE

# Build frontend image
echo "Building frontend image..."
cd ./frontend-webue
docker build --build-arg REACT_APP_API_URL=http://localhost:8080 -t ueprofiles-5gcore-frontend:latest .
cd ..

# Create namespace and apply K8s configurations
echo "Applying Kubernetes configurations..."
kubectl apply -f k8s/namespace.yml
kubectl apply -f k8s/configmap-secret.yml
kubectl apply -f k8s/mongodb/
kubectl apply -f k8s/backend/
kubectl apply -f k8s/frontend/



# Wait for deployments
echo "Waiting for deployments to be ready..."
kubectl wait --namespace ueprofiles-5gcore --for=condition=available --timeout=300s deployment/mongodb
kubectl wait --namespace ueprofiles-5gcore --for=condition=available --timeout=300s deployment/backend
kubectl wait --namespace ueprofiles-5gcore --for=condition=available --timeout=300s deployment/frontend


# # Add host entry to /etc/hosts
# echo "Updating /etc/hosts..."
# MINIKUBE_IP=$(minikube ip)
# if grep -q "${MINIKUBE_IP} ueprofiles.local" /etc/hosts; then
#   echo "Had entry in /etc/hosts"
# else
#   echo "${MINIKUBE_IP} ueprofiles.local" | sudo tee -a /etc/hosts
# fi

# Setup port-forwarding
echo "Setting up port-forwarding..."

# Kill any existing port-forwarding processes
pkill -f "kubectl port-forward.*ueprofiles-5gcore" || true

# Start port-forwarding in background
kubectl port-forward -n ueprofiles-5gcore svc/backend 8080:8080 &
BACKEND_PID=$!
kubectl port-forward -n ueprofiles-5gcore svc/frontend 3000:3000 &
FRONTEND_PID=$!

# Save PIDs for cleanup
echo $BACKEND_PID > backend_pf.pid
echo $FRONTEND_PID > frontend_pf.pid

echo "Port-forwarding established!"
echo ""
echo "Application deployed successfully!"
echo "Access frontend at: http://localhost:3000"
echo "API endpoint at: http://localhost:8080"
echo ""

#echo "Application deployed successfully!"
#echo "Access frontend at: http://ueprofiles.local"
#echo "API endpoint at: http://ueprofiles.local/api"