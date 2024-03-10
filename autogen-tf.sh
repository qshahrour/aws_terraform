#!/bin/bash

## shellcheck disable=SC2088
## shellcheck disable=SC2164
pushd "~/environment/aws2tf" &>/dev/null

TGIDS=$( aws ec2 describe-transit-gateways --query "TransitGateways[].TransitGatewayId" | jq .[] )

for J in ${TGIDS}; do
TGID=$( echo $J| tr -d '"' )
./aws_tf.sh -t tgw -i "${TGID}"
done

VPCID=$( aws ec2 describe-vpcs --filters "Name=isDefault,Values=false" --query "Vpcs[].VpcId" | jq .[] )

# shellcheck disable=SC2034
for V in $VPCID ; do
./aws_tf.sh -t vpc -V "${VPCID}" -c yes
done

./aws_tf.sh -t inst -c yes


echo "default_password_lifetime = 30"  >>  /etc/mysql/mysql.conf.d/mysqld.cnf
# ==================
## Configure MySQL Remote Access ##

sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
service mysql restart
# ==================
export MYSQL_PWD=YPE9ftktM@2024
mysql -uroot -p'YPE9ftktM@2024' -A
# =================================
mysql --user="root" -p -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY ''Rhsl$%2022";#
mysql --user="root" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;"
mysql --user="root" -e "CREATE USER 'qa'@'%' IDENTIFIED BY '';"
mysql --user="root" -e "CREATE USER 'qa'@'%' IDENTIFIED BY '';"
mysql --user="root" -e "GRANT ALL PRIVILEGES ON *.* TO 'qa'@'%' WITH GRANT OPTION;"
mysql --user="root" -e "GRANT ALL ON *.* TO 'qa'@'%' WITH GRANT OPTION;"
mysql --user="root" -e "FLUSH PRIVILEGES;"
mysql --user="root" -e "CREATE DATABASE masterminds character set UTF8mb4 collate utf8mb4_bin;"
mysql --user="root" -e "CREATE DATABASE investingelf character set UTF8mb4 collate utf8mb4_bin;"

# =================================
tee /home/ubuntu/.my.cnf <<EOF
[mysqld]
character-set-server            = utf8mb4
collation-server                = utf8mb4_bin
max_connections                 = 100
connect_timeout                 = 5
wait_timeout                    = 600
max_allowed_packet              = 16M
thread_cache_size               = 128
sort_buffer_size                = 4M
bulk_insert_buffer_size         = 16M
tmp_table_size                  = 32M
max_heap_table_size             = 32M
tmpdir                          = /tmp
lc_messages_dir                 = /usr/share/mysql
lc_messages                     = en_US
skip-external-locking
myisam_recover          		    = BACKUP
key_buffer_size     			      = 128M
#open-files-limit   			      = 2000
table_open_cache    			      = 400
myisam_sort_buffer_size 		    = 512M
concurrent_insert   			      = 2
read_buffer_size    			      = 2M
read_rnd_buffer_size    		    = 1M
innodb_buffer_pool_size 		    = 20G
innodb_log_buffer_size  		    = 8M
innodb_file_per_table   		    = 1
innodb_open_files   			      = 400
innodb_io_capacity  			      = 400
innodb_flush_method 			      = O_DIRECT
EOF
sudo service mysql restart
# =================================
