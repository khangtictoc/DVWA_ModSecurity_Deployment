#! /bin/bash

read -p "Enter your current PHP version (in short, for example '7.4'): " php_v_old
read -p "Enter your desired PHP version (in short, for example '8.2'): " php_v_new

php_v_old="${php_v_old#"${php_v_old%%[![:space:]]*}"}"   # remove leading whitespace
php_v_new="${php_v_new%"${php_v_new##*[![:space:]]}"}"   # remove trailing whitespace

sudo dpkg -l | grep php | tee packages.txt

sudo apt install apt-transport-https lsb-release ca-certificates wget -y
sudo wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg 
sudo sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
sudo apt update

# Expand the curly braces with all extensions necessary.
sudo apt install binutils
sudo apt install php$php_v_new php$php_v_new-cli php$php_v_new-{bz2,curl,mbstring,intl}

sudo apt install php8.2-fpm
# OR
# sudo apt install libapache2-mod-php$php_v_new

sudo a2enconf php$php_v_new-fpm

# When upgrading from older PHP version:
sudo a2disconf php$php_v_old-fpm

## Remove old packages
sudo apt purge php$php_v_old*

# Post-installed

sudo apt clean
sudo apt autoremove