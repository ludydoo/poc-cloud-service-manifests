#!/usr/bin/env bash

cat <<EOF | kubectl apply -f-
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: bootstrap
  namespace: default
spec:
  project: default
  source:
    repoURL: https://github.com/ludydoo/poc-cloud-service-manifests
    targetRevision: HEAD
    path: bootstrap
  destination:
    server: https://kubernetes.default.svc
    namespace: default
EOF