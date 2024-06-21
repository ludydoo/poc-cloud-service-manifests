#!/usr/bin/env bash

cat <<EOF | kubectl apply -f-
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: bootstrap
  namespace: openshift-gitops
spec:
  project: default
  syncPolicy:
    automated: {}
  source:
    repoURL: https://github.com/ludydoo/poc-cloud-service-manifests
    targetRevision: HEAD
    path: bootstrap
  destination:
    server: https://kubernetes.default.svc
    namespace: default
EOF

function create_namespaces() {
  for ns in "$@"; do
    if [ -z "$(oc get ns "$ns" -o name)" ]; then
      oc create ns "$ns"
    fi
    # This grants permissions to ArgoCD to deploy applications to these namespaces
    oc label ns "$ns" argocd.argoproj.io/managed-by=openshift-gitops
  done
}

create_namespaces cloud-service-ci cloud-service minio-operator terraform-state-store cluster-secret-operator

# Create webhook secrets
if [ -z "$(oc get secret -n cloud-service-ci generic-webhook-secret -o name)" ]; then
  oc create secret generic generic-webhook-secret -n cloud-service-ci --from-literal=WebHookSecretKey=$(openssl rand -hex 20)
fi
if [ -z "$(oc get secret -n cloud-service-ci github-webhook-secret -o name)" ]; then
  oc create secret generic github-webhook-secret -n cloud-service-ci --from-literal=WebHookSecretKey=$(openssl rand -hex 20)
fi

# Allow cloud-service to pull images from cloud-service-ci
oc policy add-role-to-user system:image-puller system:serviceaccount:cloud-service:default --namespace=cloud-service-ci

