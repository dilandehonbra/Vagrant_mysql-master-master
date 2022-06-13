#!/usr/bin/env bash

###NET_CONFIG###
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
echo "192.168.150.151 NODE01" >> /etc/hosts
echo "192.168.150.152 NODE02" >> /etc/hosts
###NET_CONFIG###

##REPOS##
sudo sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sudo sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
##REPOS##

####################################################################################################################

##INSTALL##
        sudo dnf install https://repo.mysql.com//mysql80-community-release-el8-2.noarch.rpm -y
        sudo yum module disable mysql -y
        sudo dnf install mysql-community-server -y --nogpgcheck
        sudo systemctl enable --now mysqld
##INSTALL##


###Mysld PRE-CONFIG###
        sudo awk '{ print "[client]\nuser=root\nhost=localhost\npassword="$1 }' <<<$(sudo awk -F": " '/temporary password/ {print $2}' /var/log/mysqld.log) > /home/vagrant/.my.cnf ; sudo cp /home/vagrant/.my.cnf /root/.my.cnf
          sudo awk '{ print "###MYSQL_CONFIG###\nbind-address = 0.0.0.0\nserver-id =",$1"\nlog_bin = mysql-bin\n###MYSQL_CONFIG###" }' <<<$(sudo hostname | sed 's/NODE0//g') >> /etc/my.cnf
###Mysld PRE-CONFIG###

####################################################################################################################

###Apply PRE-CONFIG###


###Apply PRE-CONFIG###

###Mysld CONFIG###

sudo mysql -u root -e "ALTER USER USER() IDENTIFIED BY 'DlsPtrd#2022';" --connect-expired-password

PASS_MYSQL=password=\'DlsPtrd#2022\'

sudo sed -i "s/password=.*/$PASS_MYSQL/g" /root/.my.cnf

sudo mysql -u root -e "CREATE USER 'repl'@'NODE01' IDENTIFIED BY 'DlsPtrd#2022'; GRANT REPLICATION SLAVE ON *.* TO 'repl'@'NODE01'; GRANT ALL PRIVILEGES ON *.* TO 'repl'@'NODE01';"
sudo mysql -u root -e "CREATE USER 'repl'@'NODE02' IDENTIFIED BY 'DlsPtrd#2022'; GRANT REPLICATION SLAVE ON *.* TO 'repl'@'NODE02'; GRANT ALL PRIVILEGES ON *.* TO 'repl'@'NODE02';"

###Mysld CONFIG###

#Apply CONFIG##
sudo systemctl restart mysqld
#Apply CONFIG##

###NODE02 SLAVE###

if [ "$(hostname)" == "NODE02" ]

        then

sudo mysql -u root -e "stop replica;"

LOG_FILE=$(sudo mysql -u repl -h NODE01 -e "SHOW MASTER STATUS\G" | awk '/File/ { print $2 }')
LOG_POSITION=$(sudo mysql -u repl -h NODE01 -e "SHOW MASTER STATUS\G" | awk '/Position/ { print $2 }')

sudo mysql -u root -e "CHANGE REPLICATION SOURCE TO SOURCE_HOST='NODE01', SOURCE_USER='repl', SOURCE_PORT=3306, SOURCE_PASSWORD='DlsPtrd#2022', SOURCE_LOG_FILE='$LOG_FILE', SOURCE_LOG_POS=$LOG_POSITION, SOURCE_SSL=1;"

sudo mysql -u root -e "start replica;"

###NODE01 SLAVE###

sudo mysql -u repl -h NODE01 -e "stop replica;"

LOG_FILE=$(sudo mysql -u root -e "SHOW MASTER STATUS\G" | awk '/File/ { print $2 }')
LOG_POSITION=$(sudo mysql -u root -e "SHOW MASTER STATUS\G" | awk '/Position/ { print $2 }')

sudo mysql -u repl -h NODE01 -e "CHANGE REPLICATION SOURCE TO SOURCE_HOST='NODE02', SOURCE_USER='repl', SOURCE_PORT=3306, SOURCE_PASSWORD='DlsPtrd#2022', SOURCE_LOG_FILE='$LOG_FILE', SOURCE_LOG_POS=$LOG_POSITION, SOURCE_SSL=1;"

sudo mysql -u repl -h NODE01 -e "start replica;"



        else
                echo "Sera executado em NODE02"

fi
###Mysld CONFIG###

####################################################################################################################
