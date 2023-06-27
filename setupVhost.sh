#! /bin/bash

# Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color


sudo apt update  && sudo apt upgrade -y


# Installing apache server 

sudo apt install apache2 zip unzip
sudo systemctl start apache2   # starting apache2 on startup


# installing maria-db server and creating  user 

sudo apt install mariadb-server
sudo systemctl start mariadb
# sudo systemctl start mariadb # starting mariad on startup
echo "##################################################"
echo "#             Setting up Mariadb user             "
echo "##################################################"
 
echo "Enter Username for Mariadb-Server : "
read username

echo "Enter the hostname :  " 
read host

echo "Enter password for  $username : " 
read password

sql="CREATE USER '$username'@'$host' IDENTIFIED BY '$password';GRANT ALL PRIVILEGES ON *.* TO '$username'@'$host' WITH GRANT OPTION;"


sudo mysql -e "$sql"

# Check the exit code of the mysql command
if [ $? -eq 0 ]; then
    echo "User $username created successfully."
else
    echo "Failed to create user $username."
fi

# Settig up phpMyAdmin
echo "##################################################"
echo "#             Setting up  phpMyAdmin              "
echo "##################################################"

sleep(1)

echo "Note : The phpMyAdmin version is the latest available at the time the script was being written."
echo " If you want the latest version, remember to enter the latest URL"
sleep(3)
read -p "Enter latest url for phpMyAdmin.zip (NA for default)" phpUrl
if [ $phpUrl -eq 'NA' ]; then
    wget https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.zip
else
    wget $phpUrl
fi

unzip php*.zip

rm  php*.zip

sudo mv php* /var/www/html/phpMyAdmin

#  Enabling  some modules

sudo a2enmod rewrite

echo "##################################################"
echo "#           Setting up  Virtual Host              "
echo "##################################################"

read -p "Do you have a host file already ? [y/n]"  res

if [ $res -eq 'YES' ]; then
    read -p " Enter the path of  host file : " path
    sudo mv  $path /etc/apache2/sites-available/
    read -p " Enter the name of host file : "  host  
    sudo a2ensite "$host.conf"
    sudo service apache2 restart
else
read -p "Enter domain name : " domain
	documentRoot="/var/www/$domain"
	vhostFile="/etc/apache2/sites-available/$domain.conf"
	# Create document root directory
	sudo mkdir -p "$documentRoot"
# Create virtual host configuration file
sudo tee "$vhostFile" > /dev/null << EOF
<VirtualHost *:80>
    ServerName $domain
    DocumentRoot $documentRoot

    <Directory $documentRoot>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/$domain-error.log
    CustomLog \${APACHE_LOG_DIR}/$domain-access.log combined
</VirtualHost>
EOF

# Enable the virtual host
sudo a2ensite "$domain.conf"

# Restart Apache to apply the changes
sudo service apache2 restart
  
fi 
  echo "Virtual host for $domain has been set up successfully."
 
