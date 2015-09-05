#!/bin/bash

# Exit if anything fails
set -e

db_username=$1
db_password=$2
rds_host=$3
rds_port=$4
bastion_host=$5
private_key=$6

pushd ../tools

# Install mysql
mkdir mysql
cd mysql
wget http://downloads.mysql.com/archives/get/file/mysql-5.6.19-linux-glibc2.5-x86_64.tar.gz
gunzip -cdfv mysql-5.6.19-linux-glibc2.5-x86_64.tar.gz | tar -vx 
export PATH="${PATH}:${PWD}/bin"
cd ..

popd

echo "-----BEGIN RSA PRIVATE KEY-----" > key.pem
echo "${private_key}" >> key.pem
echo "-----END RSA PRIVATE KEY-----" >> key.pem

ssh -L 3306:${rds_host}:${rds_port} ubuntu@${bastion_host} -i key.pem &

sleep 10

mysql -P 3306 --user=${db_username} --password=${db_password} < ./setup.sql
