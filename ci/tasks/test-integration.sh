#!/usr/bin/env bash

set -eux -o pipefail

function copy_to_remote_host() {
  local_file=$1
  remote_path=$2

  scp ${local_file} ${agent_ip}:/tmp/remote-file
  ${ssh_command} "sudo mv /tmp/remote-file ${remote_path}"
}

script_dir=$(dirname "$0")
bosh_agent_dir=$( cd "${script_dir}"/../.. && pwd )
workspace_dir=$( cd "${bosh_agent_dir}"/.. && pwd )
agent_creds_path="${workspace_dir}/agent-creds.yml"
agent_vm_key_path="${workspace_dir}/agent-key.pem"
jumpbox_key_path="${workspace_dir}/jumpbox-key.pem"

mkdir -p ~/.ssh

#TEMPORARY
agent_creds_path="${bosh_agent_dir}/agent-creds.yml"

jumpbox_url=${JUMPBOX_URL:-${JUMPBOX_IP}:22}
jumpbox_private_key_path=$(mktemp)
chmod 600 ${jumpbox_private_key_path}
echo "${JUMPBOX_PRIVATE_KEY}" > ${jumpbox_private_key_path}

export BOSH_ALL_PROXY=ssh+socks5://${JUMPBOX_USERNAME}@${jumpbox_url}?private-key=${jumpbox_private_key_path}
#END TEMPORARY


echo "${JUMPBOX_PRIVATE_KEY}" > ${jumpbox_key_path}
chmod 600 ${jumpbox_key_path}

deployment_name="bosh-agent-integration"

# generate ssh keys
#bosh interpolate ${bosh_agent_dir}/integration/assets/agent-deployment.yml \
#  --vars-store=${agent_creds_path} > /dev/null
#
#bosh -n -d ${deployment_name} deploy ${bosh_agent_dir}/integration/assets/agent-deployment.yml \
#  -v deployment_name=${deployment_name} \
#  -v stemcell_os=ubuntu-xenial \
#  --vars-file=${agent_creds_path}

bosh interpolate --path=/ssh_creds/private_key ${agent_creds_path} > ${agent_vm_key_path}
chmod 600 ${agent_vm_key_path}

agent_ip="$(bosh -d bosh-agent-integration instances --json --column ips | jq -r .Tables[].Rows[].ips)"

echo "
Host ${JUMPBOX_IP}
  User ${JUMPBOX_USERNAME}
  IdentityFile ${jumpbox_key_path}

Host ${agent_ip}
  User vcap
  IdentityFile ${agent_vm_key_path}
  ProxyJump ${JUMPBOX_IP}
" > ~/.ssh/config

ssh_command="ssh ${agent_ip}"

ssh-keyscan -H ${JUMPBOX_IP} >> ~/.ssh/known_hosts
ssh ${JUMPBOX_USERNAME}@${JUMPBOX_IP} "ssh-keyscan -H ${agent_ip}" >> ~/.ssh/known_hosts

#echo -e "\n Creating agent_test_user"
#${ssh_command} "sudo useradd agent_test_user"
#${ssh_command} "sudo usermod -G bosh_sshers,bosh_sudoers agent_test_user"
#${ssh_command} "sudo usermod -s /bin/bash agent_test_user"
#${ssh_command} "sudo mkdir -p /home/agent_test_user/.ssh"
#${ssh_command} "sudo cp /home/vcap/.ssh/authorized_keys /home/agent_test_user/.ssh/authorized_keys"
#${ssh_command} "sudo chown -R agent_test_user:agent_test_user /home/agent_test_user/"

echo "
Host ${JUMPBOX_IP}
  User ${JUMPBOX_USERNAME}
  IdentityFile ${jumpbox_key_path}
Host ${agent_ip}
  User agent_test_user
  IdentityFile ${agent_vm_key_path}
  ProxyJump ${JUMPBOX_IP}
" > ~/.ssh/config

cd ${bosh_agent_dir}
echo -e "\n Building agent..."
bin/build

echo -e "\n Installing agent..."
${ssh_command} "sudo sv stop agent"
copy_to_remote_host ${bosh_agent_dir}/out/bosh-agent /var/vcap/bosh/bin/bosh-agent

echo -e "\n Installing fake registry..."
pushd ${bosh_agent_dir}/integration/fake-registry
  go build .
  copy_to_remote_host ./fake-registry /home/agent_test_user/fake-registry
popd

echo -e "\n Installing fake blobstore..."
pushd ${bosh_agent_dir}/integration/fake-blobstore
  go build .
  copy_to_remote_host ./fake-blobstore /home/agent_test_user/fake-blobstore
popd
#sleep 600000
echo -e "\n Running agent integration tests..."
pushd ${bosh_agent_dir}
  echo "
Host agent_vm
User agent_test_user
Hostname ${agent_ip}
Port 22
IdentityFile ${agent_vm_key_path}

Host jumpbox
User ${JUMPBOX_USERNAME}
Hostname ${JUMPBOX_IP}
Port 22
IdentityFile ${jumpbox_key_path}
" > integration/ssh-config

  unset BOSH_ALL_PROXY
  export AGENT_IP=${agent_ip}
  export AGENT_USER="agent_test_user"
  go run github.com/onsi/ginkgo/ginkgo -trace -progress integration
popd


