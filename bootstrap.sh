echo "--- Updating packages list ---"
sudo apt-get update

echo "--- Install nginx and php5-fpm packages ---"
sudo apt-get -y install curl php5-mysql php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-sqlite php5-tidy php5-xmlrpc php5-xsl php5-xdebug php5-xcache php5-cli php5-xdebug php5-xcache

echo "--- Install MySQL 5.5 ---"
sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password mysecretpassword'
sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password mysecretpassword'
sudo apt-get -y install mysql-server-5.5 php5-mysql

echo "--- Enable debug php5 settings ---"
cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.max_nesting_level = 250
xdebug.var_display_max_depth = -1
xdebug.var_display_max_children = -1
xdebug.var_display_max_data = -1
EOF

sed -i "s/error_reporting = .*/error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT & ~E_NOTICE/" /etc/php5/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/fpm/php.ini

echo "--- Install git, and configure ---"
sudo apt-get install git -y
git config --global user.name "Zlatko Hristov"
git config --global user.email "zlatko.2create@gmail.com"

echo "--- Install Node.JS ---"
curl --silent --location https://deb.nodesource.com/setup_0.12 | sudo bash -
sudo apt-get -y install nodejs

echo "--- Install composer, nice ---"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

echo "--- Everything look great, master :) ---"