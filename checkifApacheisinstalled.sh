#! /usr/bin/bash

# Function to check if Apache is installed
check_apache_installed() {
    if command -v apache2 >/dev/null 2>&1 || command -v httpd >/dev/null 2>&1; then
        echo "Apache is installed."
    else
        echo "Apache is not installed."
    fi
}

# Function to check if Apache is installed using package managers
check_apache_installed_with_pkg_manager() {
    # Check for Debian-based systems
    if dpkg -l | grep -q apache2; then
        echo "Apache is installed (Debian-based system)."
    elif rpm -q httpd >/dev/null 2>&1; then
        # Check for Red Hat-based systems
        echo "Apache is installed (Red Hat-based system)."
    else
        echo "Apache is not installed."
    fi
}

# Run the functions
check_apache_installed
check_apache_installed_with_pkg_manager
