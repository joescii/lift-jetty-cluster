#!/bin/bash -eux

sudo mkdir /opt/lift
cd /opt/lift
sudo gunzip -cdfv /tmp/app.tar.gz | sudo tar -vx 
rm /tmp/app.tar.gz

# Set up our user
sudo useradd --home-dir /opt/lift lift
sudo mkdir /opt/lift/.ssh
sudo mv /tmp/authorized_keys /opt/lift/.ssh/authorized_keys
sudo chown -R lift /opt/lift

sudo chmod 755 /opt/lift/target/universal/stage/bin/lift-jetty-cluster-aws
