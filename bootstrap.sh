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

# change nginx configuration
sudo sed -i 's/sendfile on;/sendfile off;/' /etc/nginx/nginx.conf
sudo sed -i 's/# server_tokens off;/server_tokens off;\n\tclient_max_body_size 128M;/' /etc/nginx/nginx.conf
cat << EOF | sudo tee -a /etc/nginx/fastcgi_params
fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
EOF

# change date.timezone, post_max_size and upload_max_size for php5-fpm
sudo sed -i "s/;date.timezone =.*/date.timezone = $2/g" /etc/php5/fpm/php.ini
sudo sed -i "s/post_max_size = .*/post_max_size = 64M/g" /etc/php5/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 64M/g" /etc/php5/fpm/php.ini

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
sudo openssl genrsa -out /etc/nginx/ssl/nginx.key 2048
sudo openssl req -new -x509 -key /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.cert -days 3650 -subj /CN=development

echo "--- Install MySQL 5.5 and allow remote login for root ---"
sudo debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password password $1"
sudo debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password_again password $1"
sudo apt-get -y install mysql-server-5.5 php5-mysql
sudo sed -i 's/bind-address/# bind-address/g' /etc/mysql/my.cnf
mysql -uroot -p$1 -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$1';FLUSH PRIVILEGES;";

echo "--- Install phpmyadmin ---"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $1"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $1"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $1"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get -y install phpmyadmin

echo "--- Remove apache2 ---"
sudo service apache2 stop 
sudo apt-get purge apache2 apache2-utils apache2.2-bin apache2-common
sudo apt-get autoremove 
sudo rm -rf /etc/apache2

echo "--- Install git, and configure ---"
sudo apt-get install git -y
git config --global user.name "$3"
git config --global user.email "$4"

echo "--- Install Ruby on Rails and Sass"
sudo apt-get install ruby-full rubygems -y
sudo gem install sass

echo "--- Install Node.JS ---"
curl -sL https://deb.nodesource.com/setup_5.x | sudo -E bash -
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

echo "--- Remove default nginx host and create new development"
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default
echo 'server {
	server_name _;

	listen 80 default_server;
	listen [::]:80 default_server;

	root /var/www;

	index index.html index.htm index.nginx-debian.html;

	location / {
		autoindex on;
		try_files $uri $uri/ =404;
	}

	location /phpmyadmin {
	   root /usr/share/;
	   index index.php index.html index.htm;
	   location ~ ^/phpmyadmin/(.+\.php)$ {
			root /usr/share/;
			try_files $uri =404;
			include /etc/nginx/fastcgi_params;
			fastcgi_pass unix:/var/run/php5-fpm.sock;
			fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
	   }
	   location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
		   root /usr/share/;
	   }
    }
	
	location ~ \.php$ {
		include snippets/fastcgi-php.conf;
		fastcgi_pass unix:/var/run/php5-fpm.sock;
	}

	location ~* .(jpg|jpeg|png|gif|ico|css|js)$ {
		expires 1y;
		access_log off;
		add_header Cache-Control "public";
	}
	
	location ~ /\.ht {
		deny all;
	}
	
	error_log /var/log/nginx/development.error.log;
    access_log /var/log/nginx/development.access.log;
}' > /etc/nginx/sites-available/development
sudo ln -s /etc/nginx/sites-available/development /etc/nginx/sites-enabled/development

echo "--- Restart nginx and mysql ---"
sudo service nginx restart
sudo service mysql restart

echo "--- Everything look great, master :) ---"
