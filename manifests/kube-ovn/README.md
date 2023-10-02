# Kube-OVN

Installation:

```bash
$ kubectl label no -lbeta.kubernetes.io/os=linux kubernetes.io/os=linux --overwrite
$ kubectl label no -lnode-role.kubernetes.io/control-plane  kube-ovn/role=master --overwrite

$ kubectl kustomize ./manifests/kube-ovn --enable-helm | kubectl apply -f -
```
