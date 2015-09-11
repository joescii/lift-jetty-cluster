#!/bin/bash
# user_data.sh runs as root during the first boot of the EC2.
# Any variables like ${db_host} are replaced by terraform at build time.

# Exit if anything fails
set -e

# Putting our stuff in /etc/rc.local so it will run if the instance is ever rebooted,
# although operationally that should never happen.
sh -c "cat > /etc/rc.local" <<EOF
export DB_HOST=${db_host}
export DB_PORT=${db_port}
cd /opt/lift/
sudo -E -H -u lift nohup /opt/lift/target/universal/stage/bin/lift-jetty-cluster-aws > /opt/lift/log.txt
EOF

chmod 755 /etc/rc.local
/etc/rc.local
