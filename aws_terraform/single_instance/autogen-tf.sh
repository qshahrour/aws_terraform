#!/bin/bash

pushd &>/dev/null ~/environment/aws2tf

TGIDS=$( aws ec2 describe-transit-gateways --query "TransitGateways[].TransitGatewayId" | jq .[] )

for j in ${TGIDS}; do
TGID=$( echo $J| tr -d '"' )
./aws_tf.sh -t tgw -i "$TGID"
done

VPCID=$( aws ec2 describe-vpcs --filters "Name=isDefault,Values=false" --query "Vpcs[].VpcId" | jq .[] )

# shellcheck disable=SC2034
for i in VPCID ; do
./aws_tf.sh -t vpc -i "${VPCID}" -c yes
done

./aws_tf.sh -t inst -c yes


echo "default_password_lifetime = 0" >> sudo tee /etc/mysql/mysql.conf.d/mysqld.cnf
# ==================
# Configure MySQL Remote Access
sudo sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo service mysql restart
# ==================
export MYSQL_PWD=Rhsl$%2022
# =================================
mysql --user="root" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Rhsl$%2022';"#
mysql --user="root" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;"
mysql --user="root" -e "CREATE USER 'qa'@'%' IDENTIFIED BY 'Rhsl$%2022';"
mysql --user="root" -e "CREATE USER 'qa'@'%' IDENTIFIED BY 'Rhsl$%2022';"
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
myisam_recover          		= BACKUP
key_buffer_size     			= 128M
#open-files-limit   			= 2000
table_open_cache    			= 400
myisam_sort_buffer_size 		= 512M
concurrent_insert   			= 2
read_buffer_size    			= 2M
read_rnd_buffer_size    		= 1M
innodb_buffer_pool_size 		= 20G
innodb_log_buffer_size  		= 8M
innodb_file_per_table   		= 1
innodb_open_files   			= 400
innodb_io_capacity  			= 400
innodb_flush_method 			= O_DIRECT
EOF
service mysql restart
EOF
# =================================
