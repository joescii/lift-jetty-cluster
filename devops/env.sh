#!/bin/bash

# Sets up the environment for deploying.
# Downloads packer and terraform and adds them to the PATH.

# Exit if anything fails
set -e

mkdir tools
pushd tools

append=""

# Install packer
mkdir packer
cd packer
wget https://dl.bintray.com/mitchellh/packer/packer_0.8.6_linux_amd64.zip
unzip packer_0.8.6_linux_amd64.zip
append="${append}:${PWD}"
cd ..

# Install terraform
mkdir terraform
cd terraform
wget https://dl.bintray.com/mitchellh/terraform/terraform_0.6.3_linux_amd64.zip
unzip terraform_0.6.3_linux_amd64.zip
append="${append}:${PWD}"
cd ..

export PATH="${PATH}${append}"

popd
