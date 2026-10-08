#!/bin/sh

set -e

aws login

eval "$(aws configure export-credentials --profile cloud1 --format env)"

cd terraform

terraform init
terraform validate
terraform plan
terraform apply -auto-approve

# export IP=$(terraform output -raw public_ips)
terraform output -json public_ips | jq -r '.[]' > ../ips.txt

cd ..


cat > ansible/inventory.ini << EOF
[cloud1]
EOF

while read -r ip; do
    echo "$ip ansible_user=ubuntu" >> ansible/inventory.ini
done < ips.txt

cat >> ansible/inventory.ini << EOF

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

ansible-playbook -vvv \
  -i ansible/inventory.ini \
  ansible/playbook.yml \
  --private-key ~/.ssh/aws/cloud1

while read -r ip; do
    echo "https://$ip is ready !"
done < ips.txt
rm -rf ips.txt