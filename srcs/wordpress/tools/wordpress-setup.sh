#!/bin/sh

echo "Waiting for database..."
while ! nc -z mariadb 3306; do
    sleep 1
done

if [ ! -f "wp-config.php" ]; then
    echo "Downloading WordPress..."
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz --strip-components=1
    rm latest.tar.gz
    
    echo "Creating config file..."
    cp wp-config-sample.php wp-config.php
    
    sed -i "s/database_name_here/${DB_NAME}/g" wp-config.php
    sed -i "s/username_here/${DB_USER}/g" wp-config.php
    sed -i "s/password_here/${DB_PASS}/g" wp-config.php
    sed -i "s/localhost/mariadb/g" wp-config.php
    
    chown -R www-data:www-data /var/www/html
    
    echo "WordPress ready"
fi

exec php-fpm81 -F