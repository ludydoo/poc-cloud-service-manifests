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

oc adm policy add-role-to-user admin system:serviceaccount:openshift-gitops:openshift-gitops-argocd-application-controller -n