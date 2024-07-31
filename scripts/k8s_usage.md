## Setup Config

For a first time user, setup kube config
```
mkdir -p $HOME/.kube
```

Copy this below content into $HOME/.kube/config file
```
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: xxx
    server: https://k8smaster.example.net:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubernetes-admin
  name: kubernetes-admin@kubernetes
current-context: kubernetes-admin@kubernetes
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: xxx
    client-key-data: xxx
```



check if below works:
```
kubectl get nodes
kubectl get pods --all-namespaces 
```



## Dashboard

kubernetes dashboard is available on: https://xxx:31011

please use this token to login:
xxxx

you can also find this above token using:
```
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d
```



## Submit a Job

1. Create your Dockerfile, below is an example dockerfile. 


```
# Use an official CUDA image
FROM nvcr.io/nvidia/pytorch:24.06-py3

# Install necessary packages for Anaconda and other dependencies
RUN apt-get update && apt-get install -y wget git libgl1-mesa-glx && \
    rm -rf /var/lib/apt/lists/*
RUN apt-get update && \
    apt-get install -y python3 python3-pip python-is-python3

# Set the working directory in the container
WORKDIR /app

# Copy the setup script into the container
COPY setup_docker.sh /app/setup_docker.sh

# Run the setup script
RUN /bin/bash /app/setup_docker.sh

# Copy the rest of your application
#COPY . /app

# Set the default command to execute
ENTRYPOINT ["/bin/bash", "-c", "./train.sh"]
```

2. build the docker image, replace retriever-training1 with your own docker image name
```
docker build -t retriever-training1 .
```
 If there is an error with pulling images:

https://www.reddit.com/r/kubernetes/comments/1buz5fh/getting_the_status_error_errimageneverpull_but/

TLDR:  container runtime issue.
```
#save the image in .tar archive
docker save *imageName* -o *imageName*.tar

#pull the image to containerd 
sudo ctr -n=k8s.io images import *imageName*.tar

#Check the image
sudo crictl images
```

Reasons for above :

[1] docker engine shim support was discontinued by kubernetes (because it is too much work for them and to support generic cri): https://kubernetes.io/blog/2022/02/17/dockershim-faq/

[2] need to setup kubernetes with new adapter (cri-dockerd), maintained by docker and mirantis (formerly docker enterprise): https://mirantis.github.io/cri-dockerd/


Better solution for build to avoid 3 steps:

https://github.com/containerd/nerdctl
```
## to build image directly to containerd
nerdctl --namespace k8s.io build -t retriever-training1 .

## to list images
nerdctl --namespace k8s.io ps -a  
```

3. submit the job to kubernetes
```
kubectl apply -f retriever-training-job.yaml

example yaml file, the job is named as retriever-training-job1 (please change in your config):

apiVersion: batch/v1
kind: Job
metadata:
  name: retriever-training-job1
spec:
  template:
    spec:
      runtimeClassName: nvidia
      containers:
      - name: retriever-training1
        image: docker.io/library/retriever-training1:latest #if this is local image make sure to check which container runtime is used, in my case crictl to check images, because of containerd rc
		imagePullPolicy: Never # if we want the image to be pulled from local registry
        resources:
          limits:
            nvidia.com/gpu: 8 # Assuming you need 6 GPU, adjust accordingly
        volumeMounts:
        - name: app-volume
          mountPath: /app
      nodeSelector:
        kubernetes.io/hostname: k8smaster.example.net
      restartPolicy: Never
      volumes:
      - name: app-volume
        hostPath:
          path: <path> # Replace with the actual path on your Kubernetes node
          type: Directory
  backoffLimit: 2
```



## monitor the job

1. To check the status of your job:
```
kubectl get jobs
```

2. To view more detailed information about the job:
```
kubectl describe job retriever-training-job1
```

3.To check the logs of the pod created by the job:
```
kubectl logs -f <pod-name>
```
You can find the pod name by listing pods with kubectl get pods.


4. To delete the job
```
kubectl delete job retriever-training-job1
```

