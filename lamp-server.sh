#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install apache2
sudo apt-get install mysql-server libapache2-mod-auth-mysql php5-mysql
sudo mysql_install_db
sudo /usr/bin/mysql_secure_installation
sudo apt-get install php5 libapache2-mod-php5 php5-mcrypt

## Install Modules
sudo a2enmod rewrite
## Suppress qualified domain name warning
sudo sh -c 'echo "
# Suppress qualified domain name warning
ServerName localhost" >> /etc/apache2/apache2.conf'
## Allow .htaccess files
find="<Directory \/var\/www\/>\n\tOptions Indexes FollowSymLinks\n\tAllowOverride None\n\tRequire all granted\n<\/Directory>"
replace="<Directory \/var\/www\/>\n\tOptions Indexes FollowSymLinks\n\tAllowOverride All\n\tRequire all granted\n<\/Directory>"
sudo perl -0777 -i.original -pe "s/$find/$replace/igs" /etc/apache2/apache2.conf

# create prod
mkdir /var/www/html/docroot
find /var/www/html -type f -exec chmod 644 {} +
find /var/www/html -type d -exec chmod 775 {} +
chown -R root:www-data /var/www/html

# create stage
mkdir /var/www/stage
mkdir /var/www/stage/docroot
find /var/www/stage -type f -exec chmod 644 {} +
find /var/www/stage -type d -exec chmod 775 {} +
chown root:www-data /var/www/stage

# create symlink

ln -s /var/www/stage/docroot /var/www/html/docroot/stage

## Change docroot
find="DocumentRoot \/var\/www\/html"
replace="DocumentRoot \/var\/www\/html\/docroot"
sudo perl -0777 -i.original -pe "s/$find/$replace/igs" /etc/apache2/sites-available/000-default.conf

## Add user to www-data group
sudo usermod -a -G www-data $USER

sudo service apache2 restart