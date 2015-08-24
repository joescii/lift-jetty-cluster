#!/bin/bash

# Exit if anything fails
set -e

# Check that all of our vars are defined
: ${AWS_ACCESS_KEY_ID:?"Must supply AWS_ACCESS_KEY_ID environment variable"}
: ${AWS_SECRET_ACCESS_KEY:?"Must supply AWS_SECRET_ACCESS_KEY environment variable"}
: ${TF_STATE_BUCKET:?"Must supply TF_STATE_BUCKET environment variable (The S3 bucket to store terraform state)"}
: ${TF_STATE_KEY:?"Must supply TF_STATE_KEY environment variable (The S3 key to store terraform state)"}

# Create a timestamp for uniquefying stuff
timestamp=`date +"%Y%m%d%H%M%S"`

# Build and package up the application
#sbt stage
#tar -zcvf ./devops/app.tar.gz target/ 

cd ./devops

# Install packer
#mkdir packer
#cd packer
#wget https://dl.bintray.com/mitchellh/packer/packer_0.8.6_linux_amd64.zip
#unzip packer_0.8.6_linux_amd64.zip
#cd ..

# Install terraform
mkdir terraform
cd terraform
wget https://dl.bintray.com/mitchellh/terraform/terraform_0.6.3_linux_amd64.zip
unzip terraform_0.6.3_linux_amd64.zip
cd ..

# Install aws cli for using S3
pip install awscli

# Get the current terraform state
aws s3 cp s3://${TF_STATE_BUCKET}/${TF_STATE_KEY} ./terraform.tfstate

./terraform/terraform apply \
  -var "access_key=${AWS_ACCESS_KEY_ID}" \
  -var "secret_key=${AWS_SECRET_ACCESS_KEY}" \
  -var "timestamp=${timestamp}"

# If ever needed...
#./terraform/terraform destroy -force  \

# Save the terraform state 
cat ./terraform.tfstate
aws s3 cp ./terraform.tfstate s3://${TF_STATE_BUCKET}/${TF_STATE_KEY}

