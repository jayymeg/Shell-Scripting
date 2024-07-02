#! /usr/bin/bash

# Update package lists
sudo apt update

# Install Apache
sudo apt install -y apache2

# Start Apache2
sudo systemctl start apache2

# Enable Apache2 to start on boot
sudo systemctl enable apache2

# Check Apache2 status
sudo systemctl status apache2

# Install MySQL
sudo apt install -y mysql-server

# Run the MySQL secure installation wizard
sudo mysql_secure_installation

# Install PHP and necessary extensions
sudo apt install -y php libapache2-mod-php php-mysql php-cli php-curl php-gd php-mbstring php-xml php-xmlrpc

# Restart Apache to load PHP module
sudo systemctl restart apache2

# Adjust firewall to allow web traffic
sudo ufw allow in "Apache Full"

# Print status messages
echo "Apache, MySQL, and PHP installation complete!"
echo "You can check the Apache server status with: sudo systemctl status apache2"
echo "You can check the MySQL server status with: sudo systemctl status mysql"
