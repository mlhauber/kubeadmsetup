#!/bin/bash

# Install Calico Network Plugin Network
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Install Nginx Ingress
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
helm install nginx-ingress nginx-stable/nginx-ingress -n nginx-ingress

# Install Metricsserver
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server

echo 'EDIT DEPLOYMENT AFTER: kubectl edit deployment/metrics-server -nkube-system'
echo 'ADD THIS TO spec.container.args -->         - --kubelet-insecure-tls'
echo 'see https://stackoverflow.com/questions/71843068/metrics-server-is-currently-unable-to-handle-the-request'

# Install Metallb
#helm repo add metallb https://metallb.github.io/metallb
#helm install metallb metallb/metallb
#https://metallb.universe.tf/configuration/calico/
