#!/bin/bash -eux

mkdir /opt/lift
cd /opt/lift
gunzip -cdfv /tmp/app.tar.gz | tar -vx 

# Set up our user
useradd -d /opt/lift lift
echo '${user_password}' | passwd lift --stdin
echo 'lift ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
chown -R lift /opt/lift

# Add the application to startup
chmod 755 /opt/lift/universal/stage/bin/lift-jetty-cluster-aws
sudo mv /tmp/lift-svc.sh /etc/init.d/lift
sudo chmod 0750 /etc/init.d/lift

sudo update-rc.d lift 

