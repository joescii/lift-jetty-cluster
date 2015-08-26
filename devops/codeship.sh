#!/bin/bash

# Exit if anything fails
set -e

devops=`dirname $0`

echo "Script dir: ${devops}"

. ${devops}/env.sh
${devops}/deploy.sh
