#! /bin/bash

## PREDEFINED TEXT COLOR

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

## INSTALL

cd /var/www/html
git clone https://github.com/digininja/DVWA.git

sudo chmod 777 DVWA
sudo service apache2 start

# Testing apache page 

echo -e "Testing Apache Page ...\n"
result_test_page=$(curl http://127.0.0.1)

if [[ ! -z $result_test_page ]]
then
  printf "Testing Apache Page ${GREEN}[OK]${NC}\n"
else
  printf "Testing Apache Page ${RED}[FAILED]${NC}\n"
fi

# Configuring files

cd DVWA
sudo cp config/config.inc.php.dist config/config.inc.php

echo -e "Testing DVWA Page ...\n"
result_test_dvwa=$(curl http://127.0.0.1)

if [[ ! -z $result_test_dvwa ]]
then
  printf "Testing DVWA Page ${GREEN}[OK]${NC}\n"
else
  printf "Testing DVWA Page ${RED}[FAILED]${NC}\n"
fi

## Creating DB

sudo apt install mysql-server
sudo service mysql start

sudo mysql -u root -p << EOF

create database dvwa;
create user dvwa@localhost identified by 'p@ssw0rd';
grant all on dvwa.* to dvwa@localhost;
flush privileges;
use dvwa;

EOF

## REMAINING INSTALL

php_version=$(php -v | grep -o -E 'PHP [0-9]+\.[0-9]+' | cut -d ' ' -f 2)
sudo sed -i 's/^allow_url_include.*/allow_url_include = On/' /etc/php/$php_version/apache2/php.ini
sudo service apache2 restart

sudo apt update
sudo apt install php$php_version-gd


sudo chown www-data -R /var/www/html/DVWA/hackable/uploads/
sudo chown www-data -R /var/www/html/DVWA/config

sudo service apache2 restart

open http://127.0.0.1/DVWA/setup.php
