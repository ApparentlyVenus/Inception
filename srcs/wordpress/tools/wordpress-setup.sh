#!/bin/sh

echo "Waiting for database..."
# Wait for MariaDB to be ready
while ! nc -z mariadb 3306; do
    echo "Database not ready, waiting..."
    sleep 2
done

echo "Database is ready!"

# Check if WordPress is already installed
if [ ! -f "wp-config.php" ]; then
    echo "Downloading WordPress..."
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz --strip-components=1
    rm latest.tar.gz
    
    echo "Creating WordPress config file..."
    cp wp-config-sample.php wp-config.php
    
    # Configure database connection
    sed -i "s/database_name_here/${DB_NAME}/g" wp-config.php
    sed -i "s/username_here/${DB_USER}/g" wp-config.php
    sed -i "s/password_here/${DB_PASS}/g" wp-config.php
    sed -i "s/localhost/mariadb/g" wp-config.php
    
    # Set proper permissions
    chown -R nobody:nobody /var/www/html
    
    echo "WordPress configuration complete!"
else
    echo "WordPress already configured."
fi

# Install WordPress if not already installed (BEFORE starting PHP-FPM)
if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "Installing WordPress..."
    
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception Website" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root
    
    echo "Creating regular user..."
    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASS}" \
        --role=subscriber \
        --allow-root
    
    echo "WordPress installation complete!"
else
    echo "WordPress already installed."
fi

echo "Starting PHP-FPM..."
# Start PHP-FPM in foreground
exec php-fpm81 -F