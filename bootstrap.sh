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

# Create namespaces
if [ -z "$(oc get ns cloud-service-ci -o name)" ]; then
  oc create ns cloud-service-ci
fi

if [ -z "$(oc get ns cloud-service -o name)" ]; then
  oc create ns cloud-service
fi

# Label namespaces managed by ArgoCD
# This grants permissions to ArgoCD to deploy applications to these namespaces
oc label ns cloud-service-ci argocd.argoproj.io/managed-by=openshift-gitops
oc label ns cloud-service argocd.argoproj.io/managed-by=openshift-gitops

# Create webhook secrets
if [ -z "$(oc get secret -n cloud-service-ci generic-webhook-secret -o name)" ]; then
  oc create secret generic generic-webhook-secret -n cloud-service-ci --from-literal=WebHookSecretKey=$(openssl rand -hex 20)
fi
if [ -z "$(oc get secret -n cloud-service-ci github-webhook-secret -o name)" ]; then
  oc create secret generic github-webhook-secret -n cloud-service-ci --from-literal=WebHookSecretKey=$(openssl rand -hex 20)
fi


