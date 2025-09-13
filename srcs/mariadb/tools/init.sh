#!/bin/sh

# Only initialize if database doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing new database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    # Start MariaDB temporarily
    mysqld_safe --user=mysql &
    sleep 5
    
    # Set up database and users (no password needed on fresh install)
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
    mysql -u root -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';"
    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';"
    mysql -u root -e "FLUSH PRIVILEGES;"
    
    # Stop temporary instance
    mysqladmin -u root -p${DB_ROOT_PASS} shutdown
else
    echo "Database already exists, skipping initialization..."
fi

# Start MariaDB normally
exec mysqld_safe --user=mysql