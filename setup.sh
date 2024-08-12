#!/bin/bash

# Create KinD cluster
kind create cluster --config kind-config.yaml

# Deploy Prometheus and Alertmanager
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus --namespace monitoring --create-namespace
helm install alertmanager prometheus-community/alertmanager --namespace monitoring

# Deploy your application
kubectl apply -f kubernetes/alert-manager-deployment.yaml
kubectl apply -f kubernetes/alert-manager-service.yaml

# Apply Alertmanager configuration
kubectl create configmap alertmanager-config --from-file=kubernetes/prometheus-alertmanager-config.yaml -n monitoring
kubectl rollout restart deployment alertmanager -n monitoring
