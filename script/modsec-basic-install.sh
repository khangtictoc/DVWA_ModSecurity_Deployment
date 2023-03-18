#! /bin/bash

## Predefined text color

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

sudo apt install libapache2-mod-security2 -y 
sudo a2enmod headers
sudo systemctl restart apache2

sudo cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
sudo systemctl restart apache2

sudo rm -rf /usr/share/modsecurity-crs
sudo git clone https://github.com/coreruleset/coreruleset /usr/share/modsecurity-crs
sudo cp /usr/share/modsecurity-crs/crs-setup.conf.example /usr/share/modsecurity-crs/crs-setup.conf
sudo cp /usr/share/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example /usr/share/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf


## Add ModSecurity into Apache config

cat << EOF > /etc/apache2/mods-available/security2.conf

<IfModule security2_module>
        SecDataDir /var/cache/modsecurity
        Include /usr/share/modsecurity-crs/crs-setup.conf
        Include /usr/share/modsecurity-crs/rules/*.conf
</IfModule>

EOF


## Enable SecRuleEngine in site config

cat << EOF > /etc/apache2/sites-enabled/000-default.conf 

<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        SecRuleEngine On
</VirtualHost>

EOF

sudo systemctl restart apache2

## TESTING

echo -e "TESTING WAF ...\n"
echo -e "Executing command: curl http://127.0.0.1/DVWA/?exec=/bin/bash"
result_test=$(curl http://127.0.0.1/DVWA/?exec=/bin/bash | grep  "Forbidden")

if [[ ! -z $result_test ]]
then
  printf "Test: ${GREEN}[OK]${NC}"
else
  printf "Test: ${RED}[FAILED]${NC}"
fi


