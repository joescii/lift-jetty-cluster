#!/bin/bash

# Exit if anything fails
set -e

devops="$( cd "$(dirname "$0")" ; pwd )"

echo "Script dir: ${devops}"

. ${devops}/env.sh
${devops}/deploy.sh
