#!/bin/bash

# Setup for Control Plane (Master) servers
set -euxo pipefail

# CHANGE THE MASTER IP
MASTER_IP="10.0.0.1"
NODENAME=$(hostname -s)
POD_CIDR="192.168.0.0/16"

sudo kubeadm config images pull

echo "Preflight Check Passed: Downloaded All Required Images"

sudo kubeadm init --apiserver-advertise-address=$MASTER_IP --apiserver-cert-extra-sans=$MASTER_IP --pod-network-cidr=$POD_CIDR --node-name "$NODENAME" --ignore-preflight-errors Swap

mkdir -p "$HOME"/.kube
sudo cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config
sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config

kubectl cluster-info

echo 'To make kubectl available as Client on other VMs:'
echo 'curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"'
echo 'sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl'
echo 'on master: cat $HOME/.kube/config ==> copy content'
echo 'mkdir -p $HOME/.kube/'
echo 'vim $HOME/.kube/config ==> paste content'
