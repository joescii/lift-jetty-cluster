#!/bin/bash

# Exit if anything fails
set -e

devops=`dirname $0`

. ${devops}/env.sh
${devops}/deploy.sh
