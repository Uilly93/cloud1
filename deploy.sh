#!/bin/sh

set -e

eval "$(aws configure export-credentials --profile cloud1 --format env)"

cd terraform

terraform plan
terraform apply -auto-approve

IP=$(terraform output -raw public_ip)

cd ..

cat > ansible/inventory.ini << EOF
[cloud1]
$IP ansible_user=ubuntu

[cloud1:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
EOF

until ansible cloud1 \
	-i ansible/inventory.ini \
	-m ping \
	--private-key ~/.ssh/aws/cloud1 \
	>/dev/null 2>&1
do
	echo "Waiting for ssh..."
	sleep 2
done

echo "EC2 ready"

ansible-playbook \
  -i ansible/inventory.ini \
  ansible/playbook.yml \
  --private-key ~/.ssh/aws/cloud1