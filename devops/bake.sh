#!/bin/bash
# Bakes an AMI with packer

# Exit if anything fails
set -e

aws_access_key=$1
aws_secret_key=$2
aws_region=$3
vpc_id=$4
subnet_id=$5
security_group_id=$6
source_ami=$7
user_password=$8
timestamp=$9

./packer/packer build -machine-readable -color=false \
  -var "aws_access_key=${aws_access_key}" \
  -var "aws_secret_key=${aws_secret_key}" \
  -var "aws_region=${aws_region}" \
  -var "vpc_id=${vpc_id}" \
  -var "subnet_id=${subnet_id}" \
  -var "security_group_id=${security_group_id}" \
  -var "source_ami=${source_ami}" \
  -var "user_password=${user_password}" \
  -var "timestamp=${timestamp}" \
  ./packer.json \
  2>&1 | tee packer.out

packer_status=${PIPESTATUS[0]}
if [ ${packer_status} -ne 0 ]; then
  echo "Exiting with status ${packer_status}"
  exit ${packer_status}
fi

# Store the created AMI's id in a file
ami_id=`grep 'artifact,0,id' packer.out | cut -d, -f6 | cut -d: -f2`
echo "Produced AMI at ${ami_id}"
echo "${ami_id}" > ./ami.tpl
