#!/bin/bash

# Exit if anything fails
set -e

export DB_HOST=${db_host}
export DB_PORT=${db_port}

cd /opt/lift/

# Kick off the app
sudo -H -u lift nohup /opt/lift/target/universal/stage/bin/lift-jetty-cluster-aws > /opt/lift/log.txt
