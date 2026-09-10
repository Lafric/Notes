#!/usr/bin/env bash
set -euo pipefail

RG="${RG:-rg-db2-aci-test}"
LOCATION="${LOCATION:-northeurope}"
ACI_NAME="${ACI_NAME:-db2aci}"
TEMPLATE="${TEMPLATE:-./db2-aci.json}"
GENERATED="${GENERATED:-./db2-aci.generated.json}"

command -v az >/dev/null || { echo "Azure CLI is required."; exit 1; }
command -v docker >/dev/null || { echo "Docker is required locally for confcom policy generation."; exit 1; }

echo "Using resource group: $RG"
echo "Using location:       $LOCATION"
echo "Using ACI name:       $ACI_NAME"

az account show >/dev/null 2>&1 || az login

az group create \
  --name "$RG" \
  --location "$LOCATION" \
  --output none

az extension add --name confcom --upgrade --yes

# The policy generator hashes the container image layers, so make sure Docker is running.
docker info >/dev/null
docker pull icr.io/db2_community/db2:12.1.5.0

cp "$TEMPLATE" "$GENERATED"

# For this smoke test we enable debug mode so shell/stdio access is allowed.
# --approve-wildcards allows the secure Db2 password environment variable
# to be supplied at deployment time without embedding it into the CCE policy.
az confcom acipolicygen \
  --template-file "$GENERATED" \
  --approve-wildcards \
  --debug-mode

read -rsp "Db2 db2inst1 password: " DB2_PASSWORD
echo

az deployment group create \
  --resource-group "$RG" \
  --name "db2-aci-smoketest" \
  --template-file "$GENERATED" \
  --parameters \
      name="$ACI_NAME" \
      location="$LOCATION" \
      db2Password="$DB2_PASSWORD" \
  --query "properties.outputs" \
  --output json

echo
echo "Follow startup logs:"
echo "az container logs -g '$RG' -n '$ACI_NAME' --follow"
echo
echo "Inspect state/IP:"
echo "az container show -g '$RG' -n '$ACI_NAME' --query \"{state:containers[0].instanceView.currentState.state,ip:ipAddress.ip}\" -o table"
echo
echo "Open a shell after startup:"
echo "az container exec -g '$RG' -n '$ACI_NAME' --container-name db2 --exec-command '/bin/bash'"
echo
echo "Delete everything after the test:"
echo "az group delete -n '$RG' --yes --no-wait"
