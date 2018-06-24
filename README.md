# do.terraform 🐬

Getting started with `Terraform` on Digital Ocean by running a small `Kubernetes` cluster on CentOS.

## Getting started

To get the resources up and running, you need to export `digitalocean_token` as a prefixed env var :

```bash
export TF_VAR_digitalocean_token=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

## Creating the droplets

The following command will create both a master and a slave on CentOS for the kubernetes cluster:

```bash
cd terraform && terraform apply
```

## Preparing the master

First connect to the master over SSH :

```bash
ssh root@<your_master_ip>
```

Then configure the official repositories :

```bash
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://yum.kubernetes.io/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
```

Edit the selinux config to disable it `SELINUX=disabled` :

```bash
setenforce 0
vi /etc/selinux/config
```

Install the dependencies :

```bash
yum install -y docker kubelet kubeadm kubectl kubernetes-cni go git
systemctl enable docker && systemctl start docker
systemctl enable kubelet && systemctl start kubelet
```

Install go deps :

```bash
PATH=$PATH:~/go/bin
go get github.com/kubernetes-incubator/cri-tools/cmd/crictl
```

Set your iptables :

```bash
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
```

We can now init Kubernetes with `kubeadm init`.

Finally, proceed to the commands provided by `kubeadm` :

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

To ensure everything is fine, run `kubectl -n kube-config get pods`.

> Note: Copy the `kubeadm join` command to join other machines later

## Setup the network pod

Setup Calico running this command :

```bash
kubectl apply -f http://docs.projectcalico.org/v2.4/getting-started/kubernetes/installation/hosted/kubeadm/1.6/calico.yaml
```

To ensure all the pods get created well, watch it :

```bash
watch -n 0.1 kubectl --all-namespaces get pods
```

### Setup the slave

Same as master :

```bash
yum install -y docker kubelet kubeadm kubectl kubernetes-cni go git
systemctl enable docker && systemctl start docker
systemctl enable kubelet && systemctl start kubelet

PATH=$PATH:~/go/bin
go get github.com/kubernetes-incubator/cri-tools/cmd/crictl

echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
```

We can now run your `kubeadm join` command.

### Deploy the UI

Simply run :

```bash
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
```
