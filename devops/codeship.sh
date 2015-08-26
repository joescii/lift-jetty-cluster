#!/bin/bash

# Exit if anything fails
set -e

devops="$( cd "$(dirname "$0")" ; pwd )"

. ${devops}/env.sh
${devops}/deploy.sh
