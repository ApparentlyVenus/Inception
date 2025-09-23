#!/bin/sh

# Ensure we're in the right directory
cd /var/www/html

echo "Current directory: $(pwd)"
echo "Directory contents: $(ls -la)"

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

# Install WordPress if not already installed
if ! wp core is-installed --path=/var/www/html --allow-root 2>/dev/null; then
    echo "Installing WordPress..."
    
    wp core install \
        --path=/var/www/html \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception Website" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root
    
    echo "Creating regular user..."
    wp user create \
        --path=/var/www/html \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASS}" \
        --role=subscriber \
        --allow-root
    
    echo "WordPress installation complete!"
else
    echo "WordPress already installed."
fi

# Wait for Redis after WordPress is fully installed
echo "Waiting for Redis..."
while ! nc -z redis 6379; do
    echo "Redis not ready, waiting..."
    sleep 2
done

# Test Redis functionality
echo "Testing Redis functionality..."
timeout=10
while [ $timeout -gt 0 ]; do
    if redis-cli -h redis -p 6379 ping 2>/dev/null | grep -q "PONG"; then
        echo "Redis is responding!"
        break
    fi
    echo "Redis not responding, waiting... ($timeout seconds left)"
    timeout=$((timeout-1))
    sleep 1
done

# Add Redis configuration to wp-config.php (only if not already there)
# Add Redis configuration to wp-config.php (only if not already there)
if ! grep -q "WP_REDIS_HOST" wp-config.php; then
    echo "Adding Redis configuration to wp-config.php..."
    
    # Add Redis configuration to wp-config.php
    echo "" >> wp-config.php
    echo "/* Redis Configuration */" >> wp-config.php
    echo "define('WP_REDIS_HOST', 'redis');" >> wp-config.php
    echo "define('WP_REDIS_PORT', 6379);" >> wp-config.php
    echo "define('WP_REDIS_DATABASE', 0);" >> wp-config.php
    echo "define('WP_REDIS_TIMEOUT', 1);" >> wp-config.php
    echo "define('WP_REDIS_READ_TIMEOUT', 1);" >> wp-config.php
    echo "" >> wp-config.php
    
    echo "Redis configuration added to wp-config.php"
fi

# Install Redis Object Cache plugin
echo "Installing Redis Object Cache plugin..."
if ! wp plugin is-installed redis-cache --path=/var/www/html --allow-root 2>/dev/null; then
    wp plugin install redis-cache --path=/var/www/html --allow-root
    echo "Redis plugin installed"
fi

if ! wp plugin is-active redis-cache --path=/var/www/html --allow-root 2>/dev/null; then
    echo "Activating Redis Object Cache plugin..."
    wp plugin activate redis-cache --path=/var/www/html --allow-root
    echo "Redis plugin activated"
fi

# Enable Redis object cache
echo "Enabling Redis object cache..."
wp redis enable --path=/var/www/html --allow-root 2>/dev/null && echo "Redis cache enabled successfully" || echo "Redis cache enable failed or already enabled"

# Verify Redis setup
echo "Final Redis verification..."
wp redis status --path=/var/www/html --allow-root 2>/dev/null || echo "Redis status check failed"

echo "Starting PHP-FPM..."
# Start PHP-FPM in foreground
exec php-fpm81 -F