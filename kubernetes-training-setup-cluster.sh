#!/bin/bash

echo Setting up the cluster...
echo Setting IPs to env variables:
sed -i "s/<MASTER IP>/$MASTER_IP/" ~/kubernetes-training/kubeadm/kubeadm-config.yaml
sed -i "s/<PUBLIC MASTER IP>/$PUBLIC_MASTER_IP/" ~/kubernetes-training/kubeadm/kubeadm-config.yaml
# remove that whole line
sed -i "s/# Uncomment.*//" ~/kubernetes-training/kubeadm/kubeadm-config.yaml
# remove the comments
sed -i "s/# //" ~/kubernetes-training/kubeadm/kubeadm-config.yaml
sudo kubeadm init --config ~/kubernetes-training/kubeadm/kubeadm-config.yaml > kubeadm-output.txt
JOINCOMMAND=$(tail -n 2 kubeadm-output.txt | sed 's/\\//g')
ssh -o "StrictHostKeyChecking=no" worker-1 sudo $JOINCOMMAND --cri-socket="unix:///var/run/cri-dockerd.sock"
ssh -o "StrictHostKeyChecking=no" worker-2 sudo $JOINCOMMAND --cri-socket="unix:///var/run/cri-dockerd.sock"

echo Preparing kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc


echo Installing networking plugin
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml
kubectl apply -f ~/kubernetes-training/kubeadm/calico.yaml
sleep 5
kubectl wait  $(kubectl get pods -n kube-system -o name) --for condition=Ready --timeout=120s -n kube-system
kubectl label node worker-1 node-role.kubernetes.io/worker=worker
kubectl label node worker-2 node-role.kubernetes.io/worker=worker
