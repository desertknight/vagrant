#!/usr/bin/env bash
export LANG=C.UTF-8

echo "--- Updating packages list ---"
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y

echo "--- install VIM editor, and set globally ---"
sudo apt-get install -y vim
sudo update-alternatives --set editor /usr/bin/vim.basic

echo "--- Install nginx, and php5-fpm packages and edit settings ---"
sudo apt-get -y install curl nginx php5-fpm php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-sqlite php5-tidy php5-xmlrpc php5-xsl php5-xdebug php5-xcache php5-cli php5-xdebug php5-xcache

echo "--- Change OS timezone ---"
sudo vim 

# change nginx configuration
sudo sed -i 's/sendfile on;/sendfile off;/' /etc/nginx/nginx.conf
sudo sed -i 's/# server_tokens off;/server_tokens off;\n\tclient_max_body_size 128M;/' /etc/nginx/nginx.conf

# change date.timezone, post_max_size and upload_max_size for php5-fpm
sudo sed -i "s/;date.timezone =.*/date.timezone = $2/g" /etc/php5/fpm/php.ini
sudo sed -i "s/;date.timezone =.*/date.timezone = $2/g" /etc/php5/cli/php.ini
sudo sed -i "s/post_max_size = .*/post_max_size = 128M/g" /etc/php5/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 128M/g" /etc/php5/fpm/php.ini

# change xdebug basic settings
cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.max_nesting_level = 250
xdebug.var_display_max_depth = -1
xdebug.var_display_max_children = -1
xdebug.var_display_max_data = -1
EOF

sudo sed -ri 's/^error_reporting\s*=.*$/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_NOTICE/g' /etc/php5/fpm/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/g" /etc/php5/fpm/php.ini

echo "--- Create nginx ssl certs ---"
sudo mkdir /etc/nginx/ssl
sudo openssl req -x509 -new -nodes -config /vagrant/ssl/nginx -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt

echo "--- Install MySQL 5.5 and allow remote login for root ---"
sudo debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password password $1"
sudo debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password_again password $1"
sudo apt-get -y install mysql-server-5.5 php5-mysql
sudo sed -i 's/bind-address/# bind-address/g' /etc/mysql/my.cnf
mysql -uroot -p$1 -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$1';FLUSH PRIVILEGES;";

echo "--- Install git, and configure ---"
sudo apt-get install git -y
git config --global user.name "$3"
git config --global user.email "$4"

echo "--- Install Node.JS ---"
curl --silent --location https://deb.nodesource.com/setup_0.12 | sudo bash -
sudo apt-get -y install nodejs

echo "--- Install Bower globally ---"
sudo npm install -g bower

echo "--- Install composer, nice ---"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

echo "--- Install PHPUnit ---"
sudo curl https://phar.phpunit.de/phpunit.phar -o phpunit.phar
sudo chmod +x phpunit.phar
sudo mv phpunit.phar /usr/local/bin/phpunit

echo "--- Restart nginx and mysql ---"
sudo service nginx restart
sudo service mysql restart

echo "--- Everything look great, master :) ---"
