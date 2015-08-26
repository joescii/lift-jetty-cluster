#!/bin/bash -eux

sudo mkdir /opt/lift
cd /opt/lift
sudo gunzip -cdfv /tmp/app.tar.gz | sudo tar -vx 

# Set up our user
sudo useradd --home-dir /opt/lift lift
sudo chown -R lift /opt/lift

# Add the application to startup
sudo chmod 755 /opt/lift/universal/stage/bin/lift-jetty-cluster-aws
sudo mv /tmp/lift-svc.sh /etc/init.d/lift
sudo chmod 0750 /etc/init.d/lift

sudo update-rc.d lift 

