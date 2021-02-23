# Introduction to Kubernetes - Tech Olympics 2021

## Setting Up Your Workstation

### Installing Minikube

We're going to use minikube for this tutorial. So, we'll need to set it up following the 
[Getting Started](https://minikube.sigs.k8s.io/docs/start/) guide found on the minikube website. On my Mac, I simply 
used [Homebrew](https://brew.sh/):

```shell
brew install minikube
```

### Creating Your Minikube Cluster

Now that we have minikube installed, we can start our local minikube cluster: 

```shell
minikube start
```

Minikube will automatically try to detect the best driver to use by default for your platform, but sometimes it fails to
start, and you must specify the driver. Refer to the [drivers](https://minikube.sigs.k8s.io/docs/drivers/) page from the
minikube website to determine the best option. On my Mac, I typically force minikube to use the 
[HyperKit](https://minikube.sigs.k8s.io/docs/drivers/hyperkit/) driver, as that seems to work the best for my setup 
(your mileage may vary).

### Enabling the Minikube Ingress Addon

In our tutorial, we will be using an [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) 
resource to access our workload. To do so, we need to enable an ingress controller. The most popular ingress controller 
for Kubernetes is the [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/) and minikube provides an 
addon that allows us to easily install it:

```shell
minikube addons enable ingress
```

Now that we have our local minikube cluster up-and-running, it's time to put it to work!

## Kubernetes CLI (kubectl) Tour

Let's take `kubectl` for a spin:

```shell
kubectl get all
```

We should see output like this (with some likely differences in CLUSTER-IP and AGE):

```shell
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   13h
```

There isn't much running there, only the Kubernetes API `Service`. Let's try looking in other namespaces. How do we
see what namespaces are available?

```shell
kubectl get namespaces
```

We should see something similar to:

```shell
NAME              STATUS   AGE
default           Active   13h
kube-node-lease   Active   13h
kube-public       Active   13h
kube-system       Active   13h
```

Let's see what's running in the `kube-system` namespace:

```shell
kubectl get all -n kube-system
```

This should generate the following output:

```shell
NAME                                            READY   STATUS      RESTARTS   AGE
pod/coredns-74ff55c5b-wvsvr                     1/1     Running     0          13h
pod/etcd-minikube                               1/1     Running     0          13h
pod/ingress-nginx-admission-create-zb64q        0/1     Completed   0          12h
pod/ingress-nginx-admission-patch-tqgqd         0/1     Completed   2          12h
pod/ingress-nginx-controller-558664778f-fxl2t   1/1     Running     0          12h
pod/kube-apiserver-minikube                     1/1     Running     0          13h
pod/kube-controller-manager-minikube            1/1     Running     0          13h
pod/kube-proxy-4bjsf                            1/1     Running     0          13h
pod/kube-scheduler-minikube                     1/1     Running     0          13h
pod/storage-provisioner                         1/1     Running     0          13h

NAME                                         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
service/ingress-nginx-controller-admission   ClusterIP   10.107.255.247   <none>        443/TCP                  12h
service/kube-dns                             ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP   13h

NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/kube-proxy   1         1         1       1            1           kubernetes.io/os=linux   13h

NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/coredns                    1/1     1            1           13h
deployment.apps/ingress-nginx-controller   1/1     1            1           12h

NAME                                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/coredns-74ff55c5b                     1         1         1       13h
replicaset.apps/ingress-nginx-controller-558664778f   1         1         1       12h

NAME                                       COMPLETIONS   DURATION   AGE
job.batch/ingress-nginx-admission-create   1/1           5s         12h
job.batch/ingress-nginx-admission-patch    1/1           19s        12h
```

There is a way to see everything running in every namespace:

```shell
kubectl get all --all-namespaces
```

Here, we've used the `--all-namespaces` (alternatively just `-A`) flag to tell `kubectl` to gather information across 
all namespaces. What are all of these things, though? Let's `describe` one: 

```shell
kubectl describe service/kubernetes
```

The description of the Kubernetes API `Service` should look like this:

```shell
Name:              kubernetes
Namespace:         default
Labels:            component=apiserver
                   provider=kubernetes
Annotations:       <none>
Selector:          <none>
Type:              ClusterIP
IP Families:       <none>
IP:                10.96.0.1
IPs:               10.96.0.1
Port:              https  443/TCP
TargetPort:        8443/TCP
Endpoints:         192.168.64.8:8443
Session Affinity:  None
Events:            <none>
```

We can also describe other resource types. Let's check out the NGINX Ingress Controller `Pod` running in the 
`kube-system` namespace:

```shell
kubectl describe -n kube-system pod ingress-nginx-controller-558664778f-fxl2t
```