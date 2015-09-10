#!/bin/bash

# Packages and deploys the project to AWS.
# Assumes that sbt, terraform (and transitively, packer) are on the current path

# Exit if anything fails
set -e

# Check that all of our vars are defined
: ${AWS_ACCESS_KEY_ID:?"Must supply AWS_ACCESS_KEY_ID environment variable"}
: ${AWS_SECRET_ACCESS_KEY:?"Must supply AWS_SECRET_ACCESS_KEY environment variable"}
: ${TF_STATE_BUCKET:?"Must supply TF_STATE_BUCKET environment variable (The S3 bucket to store terraform state)"}
: ${TF_STATE_KEY:?"Must supply TF_STATE_KEY environment variable (The S3 key to store terraform state)"}
: ${DB_USERNAME:?"Must supply DB_USERNAME environment variable"}
: ${DB_PASSWORD:?"Must supply DB_PASSWORD environment variable"}
: ${PRIVATE_KEY:?"Must supply private SSH key"}

# Create a timestamp for uniquefying stuff
timestamp=`date +"%Y%m%d%H%M%S"`

# Build and package up the application
sbt stage
tar -zcvf ./devops/app.tar.gz target/webapp target/universal

pushd ./devops

# Terraform will complain if it doesn't see this already in place
touch ./ami.txt

# For best security, only allow Packer Builder to communicate with THIS server
publicIp=`curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//' | tr -d '\n'`
cidrBlock="${publicIp}/32"

# Toss down the private key so we can SSH as needed
echo "-----BEGIN RSA PRIVATE KEY-----" > key.pem
chmod 600 key.pem
echo "${PRIVATE_KEY}" >> key.pem
echo "-----END RSA PRIVATE KEY-----" >> key.pem

# It seems remote config only works if the default region is set to us-east-1
export AWS_DEFAULT_REGION="us-east-1" 
terraform remote config \
  -backend=S3 \
  -backend-config="bucket=${TF_STATE_BUCKET}" \
  -backend-config="key=${TF_STATE_KEY}" 

# Retrieve modules from github
terraform get

#terraform apply \
#  -var "access_key=${AWS_ACCESS_KEY_ID}" \
#  -var "secret_key=${AWS_SECRET_ACCESS_KEY}" \
#  -var "db_username=${DB_USERNAME}" \
#  -var "db_password=${DB_PASSWORD}" \
#  -var "timestamp=${timestamp}" \
#  -var "ci_server_cidr_block=${cidrBlock}" 
  
# If ever needed...
terraform destroy -force  \
  -var "access_key=${AWS_ACCESS_KEY_ID}" \
  -var "secret_key=${AWS_SECRET_ACCESS_KEY}" \
  -var "db_username=${DB_USERNAME}" \
  -var "db_password=${DB_PASSWORD}" \
  -var "timestamp=${timestamp}" 

popd