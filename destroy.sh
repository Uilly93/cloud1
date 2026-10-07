#! /bin/sh

set -e

eval "$(aws configure export-credentials --profile cloud1 --format env)"

cd terraform

terraform destroy -auto-approve