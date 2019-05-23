#!/bin/bash

artifacts_location="https://raw.githubusercontent.com/elos-tech/aks-deploy-test/master"
sp_environment=Azure

function print_usage() {
  cat <<EOF
Command
  $0
Arguments
  --app_id|-ai                       [Required] : Service principal app id  used to dynamically manage resource in your subscription
  --app_key|-ak                      [Required] : Service principal app key used to dynamically manage resource in your subscription
  --subscription_id|-si              [Required] : Subscription Id
  --tenant_id|-ti                    [Required] : Tenant Id
  --resource_group|-rg               [Required] : Resource group containing your Kubernetes cluster
  --aks_name|-an                     [Required] : Name of the Azure Kubernetes Service
  --auxvm_fqdn|-jf                 [Required] : Auxilary VM FQDN
  --artifacts_location|-al                      : Url used to reference other scripts/artifacts.
  --sas_token|-st                               : A sas token needed if the artifacts location is private.
EOF
}

function throw_if_empty() {
  local name="$1"
  local value="$2"
  if [ -z "$value" ]; then
    echo "Parameter '$name' cannot be empty." 1>&2
    print_usage
    exit 1
  fi
}

function run_util_script() {
  local script_path="$1"
  shift
  curl --silent "${artifacts_location}/${script_path}${artifacts_location_sas_token}" | sudo bash -s -- "$@"
  local return_value=$?
  if [ $return_value -ne 0 ]; then
    >&2 echo "Failed while executing script '$script_path'."
    exit $return_value
  fi
}

function install_kubectl() {
  if !(command -v kubectl >/dev/null); then
    kubectl_file="/usr/local/bin/kubectl"
    sudo curl -L -s -o $kubectl_file https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    sudo chmod +x $kubectl_file
  fi
}

function install_az() {
  if !(command -v az >/dev/null); then
    sudo apt-get update && sudo apt-get install -y libssl-dev libffi-dev python-dev
    echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/azure-cli/ wheezy main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
    sudo apt-key adv --keyserver apt-mo.trafficmanager.net --recv-keys 417A0893
    sudo apt-get install -y apt-transport-https
    sudo apt-get -y update && sudo apt-get install -y --allow-unauthenticated azure-cli
  fi
}

while [[ $# > 0 ]]
do
  key="$1"
  shift
  case "$key" in
    --app_id|-ai)
      app_id="$1"
      shift
      ;;
    --app_key|-ak)
      app_key="$1"
      shift
      ;;
    --subscription_id|-si)
      subscription_id="$1"
      shift
      ;;
    --tenant_id|-ti)
      tenant_id="$1"
      shift
      ;;
    --resource_group|-rg)
      resource_group="$1"
      shift
      ;;
    --aks_name|-an)
      aks_name="$1"
      shift
      ;;
    --auxvm_fqdn|-jf)
      auxvm_fqdn="$1"
      shift
      ;;
    --artifacts_location|-al)
      artifacts_location="$1"
      shift
      ;;
    --sas_token|-st)
      artifacts_location_sas_token="$1"
      shift
      ;;
    --help|-help|-h)
      print_usage
      exit 13
      ;;
    *)
      echo "ERROR: Unknown argument '$key' to script '$0'" 1>&2
      exit -1
  esac
done

throw_if_empty --app_id "$app_id"
throw_if_empty --app_key "$app_key"
throw_if_empty --subscription_id "$subscription_id"
throw_if_empty --tenant_id "$tenant_id"
throw_if_empty --resource_group "$resource_group"
throw_if_empty --aks_name "$aks_name"
throw_if_empty --auxvm_fqdn "$auxvm_fqdn"

install_kubectl

install_az

sudo apt-get install --yes jq

#run_util_script "artefacts/bootstrap-aks.sh" \
#    --resource_group "$resource_group" \
#    --aks_name "$aks_name" \
#    --sp_subscription_id "$subscription_id" \
#    --sp_client_id "$app_id" \
#    --sp_client_password "$app_key" \
#    --sp_tenant_id "$tenant_id" \
#    --artifacts_location "$artifacts_location" \
#    --sas_token "$artifacts_location_sas_token"

export bootstrap_aks_pid=$$
function post_logout_az() {
  while ps -p "$bootstrap_aks_pid" >/dev/null; do
    sleep 0.5
  done

  echo "Logout Azure CLI"
  az logout
}

#az login --service-principal -u "$app_id" -p "$app_key" -t "$tenant_id"
#post_logout_az & disown
#az account set --subscription "$subscription_id"
#az aks get-credentials --resource-group "${resource_group}" --name "${aks_name}" --admin

cat > /init.sh << EOF
az login --service-principal -u "$app_id" -p "$app_key" -t "$tenant_id"
az account set --subscription "$subscription_id"
az aks get-credentials --resource-group "${resource_group}" --name "${aks_name}" --admin
EOF
chmod +x /init.sh
id &> /blah
while true; do
  /init.sh &>>/blah
  kubectl get all &>>/blah && break
  sleep 20
  echo; echo; echo
done

cd
git clone https://github.com/elos-tech/kubernetes-cicd-infra.git
cd kubernetes-cicd-infra
./bootstrap.sh &>>/blah

rm -f "$temp_key_path"
rm -f "$temp_pub_key"
