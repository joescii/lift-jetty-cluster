#!/bin/bash

# Exit if anything fails
set -e

aws="$( cd "$(dirname "$0")" ; pwd )"

. ${aws}/env.sh
${aws}/deploy.sh
