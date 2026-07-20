#!/bin/bash
# Deployment script for Resume App on Docker Desktop Kubernetes
set -e

echo "=========================================="
echo "  Resume App - Kubernetes Deployment"
echo "=========================================="

echo ""
echo "[1/6] Building Docker image..."
docker build -t resume-app:local .

echo ""
echo "[2/6] Creating namespace..."
kubectl apply -f k8s/namespace.yaml

echo ""
echo "[3/6] Deploying MySQL..."
kubectl apply -f k8s/mysql-pvc.yaml
kubectl apply -f k8s/mysql-deployment.yaml
kubectl apply -f k8s/mysql-service.yaml

echo ""
echo "Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql -n resume-app --timeout=120s

echo ""
echo "[4/6] Initializing database..."
kubectl apply -f k8s/db-init-configmap.yaml
kubectl apply -f k8s/db-init-job.yaml

echo "Waiting for DB init job to complete..."
kubectl wait --for=condition=complete job/db-init -n resume-app --timeout=60s || echo "Note: Job may have completed but not detected. Continuing..."

echo ""
echo "[5/6] Deploying Resume App..."
kubectl apply -f k8s/app-config.yaml
kubectl apply -f k8s/app-pvc.yaml
kubectl apply -f k8s/app-deployment.yaml
kubectl apply -f k8s/app-service.yaml

echo ""
echo "Waiting for app to be ready..."
kubectl wait --for=condition=available deployment/resume-app -n resume-app --timeout=120s

echo ""
echo "[6/6] Deployment complete!"
echo ""
echo "=========================================="
echo "  Access your app at:"
echo "  http://localhost:30080"
echo ""
echo "  Admin login:"
echo "  URL: http://localhost:30080"
echo "  Email: admin@gmail.com"
echo "  Password: admin123"
echo "=========================================="
echo ""
echo "Useful commands:"
echo "  kubectl get all -n resume-app"
echo "  kubectl logs -n resume-app deployment/resume-app"
echo "  kubectl logs -n resume-app deployment/mysql"