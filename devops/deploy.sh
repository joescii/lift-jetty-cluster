#!/bin/bash

# Exit if anything fails
set -e

# Check that all of our vars are defined
: ${AWS_ACCESS_KEY_ID:?"Must supply AWS_ACCESS_KEY_ID environment variable"}
: ${AWS_SECRET_ACCESS_KEY:?"Must supply AWS_SECRET_ACCESS_KEY environment variable"}
: ${TF_STATE_BUCKET:?"Must supply TF_STATE_BUCKET environment variable (The S3 bucket to store terraform state)"}
: ${TF_STATE_KEY:?"Must supply TF_STATE_KEY environment variable (The S3 key to store terraform state)"}
: ${DB_USERNAME:?"Must supply DB_USERNAME environment variable"}
: ${DB_PASSWORD:?"Must supply DB_PASSWORD environment variable"}

# Create a timestamp for uniquefying stuff
timestamp=`date +"%Y%m%d%H%M%S"`

# Build and package up the application
sbt stage
tar -zcvf ./devops/app.tar.gz target/ 

cd ./devops

# Install packer
mkdir packer
cd packer
wget https://dl.bintray.com/mitchellh/packer/packer_0.8.6_linux_amd64.zip
unzip packer_0.8.6_linux_amd64.zip
cd ..

# Install terraform
mkdir terraform
cd terraform
wget https://dl.bintray.com/mitchellh/terraform/terraform_0.6.3_linux_amd64.zip
unzip terraform_0.6.3_linux_amd64.zip
cd ..
TF=./terraform/terraform

# It seems remote config only works if the default region is set to us-east-1
export AWS_DEFAULT_REGION="us-east-1" 
${TF} remote config \
  -backend=S3 \
  -backend-config="bucket=${TF_STATE_BUCKET}" \
  -backend-config="key=${TF_STATE_KEY}" 

# Retrieve modules from github
${TF} get

${TF} apply \
  -var "access_key=${AWS_ACCESS_KEY_ID}" \
  -var "secret_key=${AWS_SECRET_ACCESS_KEY}" \
  -var "db_username=${DB_USERNAME}" \
  -var "db_password=${DB_PASSWORD}" \
  -var "timestamp=${timestamp}"

# If ever needed...
#${TF} destroy -force  \
#  -var "access_key=${AWS_ACCESS_KEY_ID}" \
#  -var "secret_key=${AWS_SECRET_ACCESS_KEY}" \
#  -var "timestamp=${timestamp}"

