installation source: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

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
```
Additional Notes:
Changing Versions: To change the Kubernetes version later, you would adjust the version number in the /etc/apt/sources.list.d/kubernetes.list file and repeat the update and installation steps.


# Setup


## 1. To avoid Swap Error


The warning about swap indicates that Kubernetes generally prefers running without swap memory enabled. Kubernetes expects that memory pressure should be handled by more Kubernetes-native mechanisms like scaling rather than relying on swap, which can degrade performance.

Disabling Swap: If possible, you should disable swap to avoid issues with Kubernetes. You can do this by running:

```
sudo swapoff -a
```

And to make this change permanent, you can also comment out any swap entries in /etc/fstab.

## 2. To avoid Container Runtime Error


The error message indicates that the container runtime is not running correctly or is misconfigured. It seems to be trying to connect to containerd but is failing because the CRI (Container Runtime Interface) service is not implemented as expected.

Check Container Runtime: Make sure that containerd is installed and configured correctly. Here’s how you can ensure it’s up and running:
Restart containerd:
```
sudo systemctl restart containerd
sudo systemctl status containerd
```

If it's not installed, you can install it with:
```
sudo apt-get install containerd
sudo systemctl start containerd
sudo systemctl enable containerd
```

## 3. Configure containerd for Kubernetes


Ensure that containerd is configured for Kubernetes:

Create a default configuration file for containerd:
```
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
```

Edit the config.toml to enable the CRI plugin if it's not already enabled:
```
sudo nano /etc/containerd/config.toml
```

In the config.toml file, ensure that the [plugins."io.containerd.grpc.v1.cri"] section is uncommented and properly configured.

Restart containerd to apply the changes:
```
sudo systemctl restart containerd
```
## 4. Run kubeadm init


After ensuring that swap is disabled and containerd is properly set up, try initializing your Kubernetes cluster again:
```
sudo kubeadm init --pod-network-cidr=192.168.0.0/16
```

If you continue to encounter issues, you might consider running the command with the option to ignore pre-flight errors that you understand and deem safe to ignore, though this should be done with caution:
```
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --ignore-preflight-errors=CRI
```

However, ignoring errors should ideally be a last resort after ensuring that the issues are not critical to your cluster's operation and security.


## 5. Configure kubectl

To manage your cluster, set up kubectl on your local machine:
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

## 6. For Unreachable Issues of (kubectl get nodes --v=8)

Changing the bind address to 0.0.0.0 in the Kubernetes API server configuration would allow it to accept connections on all interfaces. This is generally a good troubleshooting step to ensure it's not an IP-specific issue.

Modifying the API Server Configuration: If you're running Kubernetes via kubeadm and want to change the bind address or any other parameters of the kube-apiserver, you'll typically need to modify the API server manifest found in /etc/kubernetes/manifests/kube-apiserver.yaml.
Find the line starting with --bind-address or --advertise-address and change it to 0.0.0.0.
Save the changes. Kubernetes should automatically restart the kube-apiserver because it watches for changes in the manifest files.

Restart and Check:
After making changes, monitor the restart and check the logs:
```
kubectl get nodes --v=8
```
successful output should be:
```
kubectl get nodes --v=8
I0625 13:36:27.210631 2371814 loader.go:395] Config loaded from file:  /home/srikanth.m/.kube/config
I0625 13:36:27.232127 2371814 round_trippers.go:463] GET https://105.128.44.27:6443/api/v1/nodes?limit=500
I0625 13:36:27.232172 2371814 round_trippers.go:469] Request Headers:
I0625 13:36:27.232196 2371814 round_trippers.go:473]     Accept: application/json;as=Table;v=v1;g=meta.k8s.io,application/json;as=Table;v=v1beta1;g=meta.k8s.io,application/json
I0625 13:36:27.232208 2371814 round_trippers.go:473]     User-Agent: kubectl/v1.30.2 (linux/amd64) kubernetes/3968350
I0625 13:36:27.247880 2371814 round_trippers.go:574] Response Status: 200 OK in 15 milliseconds
I0625 13:36:27.247925 2371814 round_trippers.go:577] Response Headers:
I0625 13:36:27.247944 2371814 round_trippers.go:580]     Cache-Control: no-cache, private
I0625 13:36:27.247956 2371814 round_trippers.go:580]     Content-Type: application/json
I0625 13:36:27.247966 2371814 round_trippers.go:580]     X-Kubernetes-Pf-Flowschema-Uid: 3605acb3-606c-42f4-ae7d-90dc5f3ce112
I0625 13:36:27.247975 2371814 round_trippers.go:580]     X-Kubernetes-Pf-Prioritylevel-Uid: 97eaeec8-72c8-4daa-849b-f7b5c8f30e6d
I0625 13:36:27.247985 2371814 round_trippers.go:580]     Date: Tue, 25 Jun 2024 20:36:27 GMT
I0625 13:36:27.247993 2371814 round_trippers.go:580]     Audit-Id: 3fe2d5e0-1fcb-494a-9e9d-2dcdf0ee7610
I0625 13:36:27.248214 2371814 request.go:1212] Response Body: {"kind":"Table","apiVersion":"meta.k8s.io/v1","metadata":{"resourceVersion":"855"},"columnDefinitions":[{"name":"Name","type":"string","format":"name","description":"Name must be unique within a namespace. Is required when creating resources, although some resources may allow a client to request the generation of an appropriate name automatically. Name is primarily intended for creation idempotence and configuration definition. Cannot be updated. More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names#names","priority":0},{"name":"Status","type":"string","format":"","description":"The status of the node","priority":0},{"name":"Roles","type":"string","format":"","description":"The roles of the node","priority":0},{"name":"Age","type":"string","format":"","description":"CreationTimestamp is a timestamp representing the server time when this object was created. It is not guaranteed to be set in happens-before order across separate operations. Clients may not set this value. It is repre [truncated 4707 chars]
NAME                STATUS     ROLES           AGE   VERSION
<node>   NotReady   control-plane   11m   v1.30.2
```

Connectivity Check:
Try connecting again using curl after ensuring the kube-apiserver has restarted with the new configuration:
```
curl -k https://105.128.44.27:6443
```
## 6. Remove Master Node Taint

check any taints
```
kubectl get nodes -o=custom-columns=NAME:.metadata.name,TAINTS:.spec.taints

NAME                TAINTS
<node>   [map[effect:NoSchedule key:node-role.kubernetes.io/control-plane] map[effect:NoSchedule key:node.kubernetes.io/not-ready]]
```
This command formats the output to show only the node names and any taints associated with them. If there are no taints, the TAINTS column will be empty.


Since this is a single-node setup and you'll want to run pods on the master node, you should remove the default taint that prevents this:

```
kubectl taint nodes <node> node-role.kubernetes.io/control-plane-
```


