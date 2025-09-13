#!/bin/sh

echo "[DB config] Configuring MariaDB..."

# Create the mysqld run directory if it doesn't exist
if [ ! -d "/run/mysqld" ]; then
    echo "[DB config] Creating MariaDB run directory..."
    mkdir -p /run/mysqld
    chown -R mysql:mysql /run/mysqld
fi

# Check if database is already initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[DB config] Initializing MariaDB database..."
    
    # Install the database
    mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --rpm > /dev/null
    
    echo "[DB config] Setting up database and users..."
    
    # Create temporary SQL file for setup
    TMP=/tmp/mysql_setup.sql
    
    # SQL commands for database setup
    echo "USE mysql;" > ${TMP}
    echo "FLUSH PRIVILEGES;" >> ${TMP}
    echo "" >> ${TMP}
    echo "-- Remove anonymous users" >> ${TMP}
    echo "DELETE FROM mysql.user WHERE User='';" >> ${TMP}
    echo "" >> ${TMP}
    echo "-- Remove test database" >> ${TMP}
    echo "DROP DATABASE IF EXISTS test;" >> ${TMP}
    echo "DELETE FROM mysql.db WHERE Db='test';" >> ${TMP}
    echo "" >> ${TMP}
    echo "-- Remove remote root access (keep only local)" >> ${TMP}
    echo "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');" >> ${TMP}
    echo "" >> ${TMP}
    echo "-- Set root password" >> ${TMP}
    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';" >> ${TMP}
    echo "" >> ${TMP}
    echo "-- Create application database" >> ${TMP}
    echo "CREATE DATABASE IF NOT EXISTS ${DB_NAME};" >> ${TMP}
    echo "" >> ${TMP}
    echo "-- Create application user with proper permissions" >> ${TMP}
    echo "CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';" >> ${TMP}
    echo "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';" >> ${TMP}
    echo "" >> ${TMP}
    echo "-- Apply changes" >> ${TMP}
    echo "FLUSH PRIVILEGES;" >> ${TMP}

    # Apply the SQL setup using bootstrap mode
    /usr/bin/mysqld --user=mysql --bootstrap --verbose=0 < ${TMP}
    
    # Clean up
    rm -f ${TMP}
    
    echo "[DB config] Database initialization completed."
else
    echo "[DB config] Database already initialized."
fi

echo "[DB config] Allowing remote connections to MariaDB..."
# Directly overwrite the problematic mariadb-server.cnf file
cat > /etc/my.cnf.d/mariadb-server.cnf << 'EOF'
#
# These groups are read by MariaDB server.
# Use it for options that only the server (but not clients) should see
# this is read by the standalone daemon and embedded servers
[server]
# this is only for the mysqld standalone daemon
[mysqld]
#skip-networking
bind-address=0.0.0.0
port=3306
# Galera-related settings
[galera]
# this is only for embedded server
[embedded]
# This group is only read by MariaDB servers, not by MySQL.
[mariadb]
# This group is only read by MariaDB-10.5 servers.
[mariadb-10.5]
EOF

echo "[DB config] Starting MariaDB server..."
# Start MariaDB in foreground (required for Docker)
exec /usr/bin/mysqld --user=mysql --console