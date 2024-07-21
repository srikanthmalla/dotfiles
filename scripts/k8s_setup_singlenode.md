installation source: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

step by step instruction: https://www.linuxtechi.com/install-kubernetes-on-ubuntu-22-04/

# Installation
## Step 1: Update the apt package index and install necessary packages

```
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
```

Note: apt-transport-https may be a dummy package in newer Ubuntu versions, meaning it's integrated into apt itself and no longer needs separate installation.

## Step 2: Set up the Kubernetes repository signing key


Create the keyring directory if it doesn’t exist (especially relevant for systems older than Debian 12 and Ubuntu 22.04):
```
sudo mkdir -p -m 755 /etc/apt/keyrings
```

Download and install the signing key:
```
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

## Step 3: Add the Kubernetes apt repository

```
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
```
Note: This command specifies the repository for Kubernetes v1.30. If you need a different version, replace v1.30 in the URL with the desired minor version.

## Step 4: Update apt package index and install kubectl

```
sudo apt-get update
sudo apt-get install -y kubectl kubelet kubeadm
sudo apt-mark hold kubelet kubeadm kubectl
```
Additional Notes:
Changing Versions: To change the Kubernetes version later, you would adjust the version number in the /etc/apt/sources.list.d/kubernetes.list file and repeat the update and installation steps.

# Setup

## 1. Setup hostname

Login to to master node and set hostname via hostnamectl command
```
sudo hostnamectl set-hostname "k8smaster.example.net"
```

On the worker nodes, run
```
sudo hostnamectl set-hostname "k8sworker1.example.net"   // 1st worker node
sudo hostnamectl set-hostname "k8sworker2.example.net"   // 2nd worker node
```

Add the following lines in /etc/hosts file on each node (adjust the ip address of the nodes)
```
<ip address of k8master node>   k8smaster.example.net k8smaster
<ip address of k8worker1 node>    k8sworker1.example.net k8sworker1
<ip address of k8worker2 node>   k8sworker2.example.net k8sworker2
```
## 2. Disable Swap and add kernel parameters


The warning about swap indicates that Kubernetes generally prefers running without swap memory enabled. Kubernetes expects that memory pressure should be handled by more Kubernetes-native mechanisms like scaling rather than relying on swap, which can degrade performance.

Disabling Swap: If possible, you should disable swap to avoid issues with Kubernetes. You can do this by running:
```
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```
And to make this change permanent, you can also comment out any swap entries in /etc/fstab.

Load the following kernel modules on all the nodes,
```
$ sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
$ sudo modprobe overlay
$ sudo modprobe br_netfilter
```


Set the following Kernel parameters for Kubernetes, run beneath tee command
```
$ sudo tee /etc/sysctl.d/kubernetes.conf <<EOT
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOT
```

Reload the above changes, run

```
$ sudo sysctl --system
```

## 3. Containered

In this guide, we are using containerd runtime for our Kubernetes cluster. So, to install containerd, first install its dependencies.
```
$ sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
```



Enable docker repository
```
$ sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
```
Now, run following apt command to install containerd
```
$ sudo apt update
$ sudo apt install -y containerd.io
```
Configure containerd so that it starts using systemd as cgroup.
```
$ containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
$ sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
```
Restart and enable containerd service
```
$ sudo systemctl restart containerd
$ sudo systemctl enable containerd
```

## 4. Run kubeadm init


After ensuring that swap is disabled and containerd is properly set up, try initializing your Kubernetes cluster again:
```
sudo kubeadm init --control-plane-endpoint=k8smaster.example.net
```
## 5. Configure kubectl


To manage your cluster, set up kubectl on your local machine:
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```


## 6. Install Calico Network Plugin


A network plugin is required to enable communication between pods in the cluster. Run following kubectl command to install Calico network plugin from the master node,
```
$ kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.0/manifests/calico.yaml
```
Output of above commands would look like below,
![image](https://github.com/srikanthmalla/dotfiles/assets/8193784/758b0b79-6846-4751-9ed1-e23cebdab4c5)

Verify the status of pods in kube-system namespace,
```
$ kubectl get pods -n kube-system
```
Output,
![image](https://github.com/srikanthmalla/dotfiles/assets/8193784/50e9af51-b09f-4236-a60e-0cfb1ca82034)

Perfect, check the nodes status as well.
```
$ kubectl get nodes
```
![image](https://github.com/srikanthmalla/dotfiles/assets/8193784/0d8b9307-3abc-47b3-b4df-93f386a1c9a8)

Great, above confirms that nodes are active node. Now, we can say that our Kubernetes cluster is functional.

## 7. Remove Master Node Taint

check any taints
```
kubectl get nodes -o=custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

NAME                TAINTS
k8smaster.example.net   [map[effect:NoSchedule key:node-role.kubernetes.io/control-plane] map[effect:NoSchedule key:node.kubernetes.io/not-ready]]
```

This command formats the output to show only the node names and any taints associated with them. If there are no taints, the TAINTS column will be empty.


Since this is a single-node setup and you'll want to run pods on the master node, you should remove the default taint that prevents this:
```
kubectl taint nodes k8smaster.example.net node-role.kubernetes.io/control-plane-
```

## 7) Setup GPU kubernetes plugin for GPU node

https://github.com/NVIDIA/k8s-device-plugin#prerequisites

https://www.jimangel.io/posts/nvidia-rtx-gpu-kubernetes-setup/



configure docker runtime (crio, containerd,..) to use nvidia container runtime. Below are steps for containerd and docker (https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#configuring-containerd-for-kubernetes):

```
sudo nvidia-ctk runtime configure --runtime=containerd

sudo systemctl restart containerd
```



nertdctl installation (if needed to test nvidia rc hook): https://www.guide2wsl.com/nerdctl/
```
NERDCTL_VERSION=1.7.6 # see https://github.com/containerd/nerdctl/releases for the latest release

archType="amd64"
if test "$(uname -m)" = "aarch64"
then
    archType="arm64"
fi

wget -q "https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-full-${NERDCTL_VERSION}-linux-${archType}.tar.gz" -O /tmp/nerdctl.tar.gz
mkdir -p ~/.local/bin
tar -C ~/.local/bin/ -xzf /tmp/nerdctl.tar.gz --strip-components 1 bin/nerdctl

echo -e '\nexport PATH="${PATH}:~/.local/bin"' >> ~/.bashrc
source ~/.bashrc
```

test:
```
# `nvidia-smi` command ran with cuda 12.3
sudo nerdctl run -it --rm --gpus all nvidia/cuda:12.3.1-base-ubuntu20.04 nvidia-smi

# `nvcc -V` command ran with cuda 12.3 (the "12.3.1-base" image doesn't include nvcc)
sudo nerdctl run -it --rm --gpus all nvidia/cuda:12.3.1-devel-ubuntu20.04 nvcc -V
```



install gpu operator using helm.
```
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
   && helm repo update


helm install --wait gpu-operator \
     -n gpu-operator --create-namespace \
      nvidia/gpu-operator \
      --set driver.enabled=false \
      --set toolkit.enabled=false
```



check the log:
```
>>kubectl get pods -n gpu-operator | grep -i nvidia

nvidia-cuda-validator-cg4mm                                  0/1     Completed   0          39s
nvidia-dcgm-exporter-gzvzk                                   1/1     Running     0          58s
nvidia-device-plugin-daemonset-574ql                         1/1     Running     0          58s
nvidia-operator-validator-dljv2                              0/1     Init:3/4    0          58s



>>kubectl -n gpu-operator logs deployment/gpu-operator | grep GPU

{"level":"info","ts":1721573814.5885231,"logger":"controllers.ClusterPolicy","msg":"GPU workload configuration","NodeName":"k8smaster.example.net","GpuWorkloadConfig":"container"}
{"level":"info","ts":1721573814.58855,"logger":"controllers.ClusterPolicy","msg":"Node has GPU(s)","NodeName":"k8smaster.example.net"}
{"level":"info","ts":1721573814.5885699,"logger":"controllers.ClusterPolicy","msg":"Checking GPU state labels on the node","NodeName":"k8smaster.example.net"}
{"level":"info","ts":1721573814.58866,"logger":"controllers.ClusterPolicy","msg":"Applying correct GPU state labels to the node","NodeName":"k8smaster.example.net"}
{"level":"info","ts":1721573814.6119583,"logger":"controllers.ClusterPolicy","msg":"Number of nodes with GPU label","NodeCount":1}
{"level":"info","ts":1721573815.6731489,"logger":"controllers.ClusterPolicy","msg":"GPU workload configuration","NodeName":"k8smaster.example.net","GpuWorkloadConfig":"container"}
{"level":"info","ts":1721573815.6731753,"logger":"controllers.ClusterPolicy","msg":"Checking GPU state labels on the node","NodeName":"k8smaster.example.net"}
{"level":"info","ts":1721573815.6731992,"logger":"controllers.ClusterPolicy","msg":"Number of nodes with GPU label","NodeCount":1}
```
