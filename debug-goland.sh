#!/usr/bin/env bash

# Copyright (c) 2019 StackRox Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# deploy.sh
#
# Sets up the environment for the admission controller webhook demo in the active cluster.

set -euo pipefail

basedir="$(dirname "$0")/deployment"
keydir="$(mktemp -d)"

# Generate keys into a temporary directory.
echo "Generating TLS keys ..."
"${basedir}/generate-keys-ip.sh" "$keydir"


# cp to /run/secrets/tls
mkdir -p /run/secrets/tls
cp ${keydir}/webhook-server-tls.crt /run/secrets/tls/tls.crt
cp ${keydir}/webhook-server-tls.key /run/secrets/tls/tls.key


# Read the PEM-encoded CA certificate, base64 encode it, and replace the `${CA_PEM_B64}` placeholder in the YAML
# MutatingWebhookConfiguration-outer.yaml with it. Then, create the Kubernetes resources.
ca_pem_b64="$(openssl base64 -A <"${keydir}/ca.crt")"
echo "[ca_pem_b64]" $ca_pem_b64

#sed -e 's@${CA_PEM_B64}@'"$ca_pem_b64"'@g' ${basedir}/deployment.yaml
#kubectl apply -f ${basedir}/deployment.yaml
sed -e 's@${CA_PEM_B64}@'"$ca_pem_b64"'@g' <"${basedir}//MutatingWebhookConfiguration-outer.yaml" \
    | kubectl apply -f -


echo "The webhook server has been deployed and configured!"
