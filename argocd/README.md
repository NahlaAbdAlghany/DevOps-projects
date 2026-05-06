
# Argocd
## ArgoCD High Availability Deployment with Kustomize on EKS

## Prerequisites

- ### Install Kustomize
```sh
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
sudo mv kustomize /usr/local/bin/
kustomize version
```

- ### AWS CLI & kubectl configured for EKS
```sh
# Configure AWS credentials
aws configure

# Update kubeconfig to point to your EKS cluster
aws eks update-kubeconfig --region <region> --name <cluster-name>

# Verify connection
kubectl get nodes
```

## ArgoCD HA Deploy

- Copy [ha/install.yaml](https://github.com/argoproj/argo-cd/blob/master/manifests/ha/install.yaml) into `base/` and create a kustomization file.
```sh
kustomize build base/
kubectl apply -k base/
```

- Create a LoadBalancer service using the overlay under `overlays/test/`. On EKS, the LoadBalancer type provisions an AWS Classic/NLB load balancer automatically via the cloud controller.
```sh
kubectl apply -k overlays/test/
```

- Get the external DNS name assigned to the ArgoCD load balancer:
```sh
kubectl get svc argocd-loadbalancer -n argocd
```

Access the ArgoCD UI at `https://<EXTERNAL-IP-or-DNS>`.

## ArgoCD Application

- From the UI, create a `default` project that accepts `*` namespaces.
- Create an application for each app:
```sh
kubectl apply -f argocd-app/
```

## Links and Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/en/release-2.5/operator-manual/installation/)
- [How to install ArgoCD in K8s cluster](https://www.youtube.com/watch?v=NI7rPEN6bGA&t=233s)
- [EKS Getting Started](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
