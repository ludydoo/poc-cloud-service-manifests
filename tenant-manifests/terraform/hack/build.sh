#!/usr/bin/env bash

set -e

# The purpose of this script is to convert the terraform manifests into a configMap

ROOT=$(git rev-parse --show-toplevel)
TF_DIR="${ROOT}/tenant-manifests/terraform"
CONFIGMAP_FILE="${ROOT}/tenant-manifests/templates/terraform-manifests.yaml"

# Create the configMap file
cat <<EOF > "${CONFIGMAP_FILE}"
apiVersion: v1
kind: ConfigMap
metadata:
  name: terraform-manifests
data:
EOF

# Add the terraform manifests to the configMap
for file in $(find "${TF_DIR}" -depth 1 -type f); do
  echo "  $(basename ${file}): |" >> "${CONFIGMAP_FILE}"
  sed 's/^/    /' "${file}" >> "${CONFIGMAP_FILE}"
  echo "" >> "${CONFIGMAP_FILE}"
done