#!/bin/bash

# Exit if anything fails
set -e

db_username=$1
db_password=$2
rds_host=$3
rds_port=$4

pushd ../tools

# Install mysql
mkdir mysql
cd mysql
wget http://downloads.mysql.com/archives/get/file/mysql-5.6.19-linux-glibc2.5-x86_64.tar.gz
gunzip -cdfv mysql-5.6.19-linux-glibc2.5-x86_64.tar.gz | sudo tar -vx 
export PATH="${PATH}:${PWD}/bin"
cd ..

sh -c "cat > setup.sql" <<EOF
create database lift_sessions;
create user 'jetty'@'localhost' identified by 'lift-rocks';
grant all on lift_sessions.* TO 'jetty'@'localhost';
EOF

mysql -h ${rds_host} -P ${rds_port} --user=${db_username} --password=${db_password} < setup.sql

popd

