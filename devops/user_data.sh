#!/bin/bash

# Exit if anything fails
set -e

sh -c "cat > /opt/lift/env.sh" <<EOF
export DB_HOST=${db_host}
export DB_PORT=${db_port}
EOF

chown -R lift /opt/lift/env.sh
chmod 755 /opt/lift/env.sh
