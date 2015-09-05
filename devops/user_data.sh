#!/bin/bash

# Exit if anything fails
set -e

sh -c "cat > /opt/lift/env.sh" <<EOF
export DB_HOST=${var.db_host}
export DB_PORT=${var.db_host}
EOF

chown -R lift /opt/lift/env.sh
chmod 755 /opt/lift/env.sh
