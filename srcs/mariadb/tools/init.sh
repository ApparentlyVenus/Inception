#!/bin/sh

# Only initialize if database doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing new database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    # Start MariaDB temporarily
    mysqld_safe --user=mysql &
    sleep 5
    
    # Connect using socket as mysql system user
    su mysql -s /bin/sh -c "mysql -u mysql -e 'CREATE DATABASE IF NOT EXISTS ${DB_NAME};'"
    su mysql -s /bin/sh -c "mysql -u mysql -e \"CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';\""
    su mysql -s /bin/sh -c "mysql -u mysql -e \"GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';\""
    su mysql -s /bin/sh -c "mysql -u mysql -e \"ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';\""
    su mysql -s /bin/sh -c "mysql -u mysql -e 'FLUSH PRIVILEGES;'"
    
    # Stop temporary MariaDB
    su mysql -s /bin/sh -c "mysqladmin -u mysql shutdown"
else
    echo "Database already exists, skipping initialization..."
fi

# Start MariaDB normally
exec mysqld_safe --user=mysql