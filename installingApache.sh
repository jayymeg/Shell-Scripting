#! /usr/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if Apache is already installed
if command_exists httpd || command_exists apache2; then
    echo "Apache is already installed."
else
    echo "Apache is not installed. Proceeding with installation."

    # Update package list
    sudo apt-get update -y

    # Install Apache
    sudo apt-get install -y apache2

    # Start Apache service
    sudo systemctl start apache2

    # Enable Apache service to start on boot
    sudo systemctl enable apache2

    echo "Apache installation completed."
fi

# Verify Apache installation
if command_exists httpd || command_exists apache2; then
    echo "Apache is installed successfully."
    # Check Apache status
    sudo systemctl status apache2
else
    echo "Failed to install Apache."
fi
