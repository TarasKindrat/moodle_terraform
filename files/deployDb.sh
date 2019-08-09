#!/bin/bash
#source settings.cfg
rootdbpass="mypassword123";
# WEB host from web connect to db
host_web="$1";
#hostdb="$2";
portdb=3306;
dbname="moodle";
moodleuser="webmoodle";
moodlepassword="yourpassword123";
echo "Disable selinux"
sudo setenforce Permissive
echo "Update and install mariadb ";
        sudo yum update -y;
        sudo yum -y install mc;
        sudo yum -y install mariadb-server;
        sudo systemctl start mariadb.service;
        sudo systemctl enable mariadb.service;
echo "Modify  mariadb and creating moodle db";

sudo mysql -u root <<-EOF
UPDATE mysql.user SET Password=PASSWORD("$rootdbpass") WHERE User='root';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
CREATE DATABASE $dbname DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON $dbname.* TO "$moodleuser"@"$host_web" IDENTIFIED BY "$moodlepassword";
FLUSH PRIVILEGES;
EOF

echo "Modify  /etc/my.cnf.d/server.cnf";

cat <<EOF > /etc/my.cnf.d/server.cnf
[client]
default-character-set = utf8mb4

[mysqld]
innodb_file_format = Barracuda
innodb_file_per_table = 1
innodb_large_prefix

character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
skip-character-set-client-handshake

[mysql]
default-character-set = utf8mb4"
EOF

echo "restarting mariadb ";
sudo systemctl restart mariadb;
echo " Job DONE!"
