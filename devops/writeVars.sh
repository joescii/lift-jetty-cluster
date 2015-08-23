#!/bin/bash
# Reads the VPC state from S3 and writes them to terraform.tfvars
# Assumes awscli and jq have been installed.

# Check that all of our vars are defined
: ${AWS_ACCESS_KEY_ID:?"Must supply AWS_ACCESS_KEY_ID environment variable"}
: ${AWS_SECRET_ACCESS_KEY:?"Must supply AWS_SECRET_ACCESS_KEY environment variable"}
: ${VPC_STATE_BUCKET:?"Must supply VPC_STATE_BUCKET environment variable (The S3 bucket to retrieve VPC terraform state)"}
: ${VPC_STATE_KEY:?"Must supply VPC_STATE_KEY environment variable (The S3 key to retrieve VPC terraform state)"}

state=./vpc.tfstate

aws s3 cp s3://${VPC_STATE_BUCKET}/${VPC_STATE_KEY} ${state}

vpc_id=`jq --raw-output '.modules[0].resources["aws_vpc.default"].primary.id' ${state} | tr -d '\r'`
subnet_private_A=`jq --raw-output '.modules[0].resources["aws_subnet.private-A"].primary.id' ${state} | tr -d '\r'`
subnet_private_B=`jq --raw-output '.modules[0].resources["aws_subnet.private-B"].primary.id' ${state} | tr -d '\r'`
subnet_public_A=`jq --raw-output '.modules[0].resources["aws_subnet.public-A"].primary.id' ${state} | tr -d '\r'`
subnet_public_B=`jq --raw-output '.modules[0].resources["aws_subnet.public-B"].primary.id' ${state} | tr -d '\r'`

cat >> terraform.tfvars << EOF
vpc_id = "${vpc_id}"
subnet_private_A = "${subnet_private_A}"
subnet_private_B = "${subnet_private_B}"
subnet_public_A = "${subnet_public_A}"
subnet_public_B = "${subnet_public_B}"
EOF
