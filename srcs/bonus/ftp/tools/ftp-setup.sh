#!/bin/sh

echo "[FTP] Starting FTP server configuration..."

# Create secure directory if it doesn't exist
mkdir -p /var/empty
chown root:root /var/empty
chmod 755 /var/empty

# Wait for WordPress volume to be ready
echo "[FTP] Waiting for WordPress volume..."
while [ ! -d "/var/www/html" ]; do
    sleep 1
done

# Create FTP user if environment variables are provided
if [ ! -z "$FTP_USER" ] && [ ! -z "$FTP_PASS" ]; then
    echo "[FTP] Creating FTP user: $FTP_USER"
    
    # Remove existing user if exists
    deluser $FTP_USER 2>/dev/null || true
    
    # Create new user with unique UID (1001) and add to nobody group for file access
    adduser -D -u 1001 -G nobody -h /var/www/html -s /bin/sh $FTP_USER
    echo "$FTP_USER:$FTP_PASS" | chpasswd
    
    echo "[FTP] User $FTP_USER created successfully with UID 1001"
else
    echo "[FTP] Creating default FTP user: ftpuser"
    deluser ftpuser 2>/dev/null || true
    # Use UID 1001 and add to nobody group for file permissions
    adduser -D -u 1001 -G nobody -h /var/www/html -s /bin/sh ftpuser
    echo "ftpuser:ftppass123" | chpasswd
    echo "[FTP] User ftpuser created successfully with UID 1001"
fi

# Set WordPress directory permissions for FTP access
if [ -d "/var/www/html" ]; then
    echo "[FTP] Setting up WordPress directory permissions..."
    
    # Make the directory group-writable so FTP user (in nobody group) can write
    chmod 775 /var/www/html
    
    # If WordPress files exist, adjust permissions
    if [ "$(ls -A /var/www/html)" ]; then
        echo "[FTP] WordPress files detected, adjusting permissions..."
        # Make directories group-writable
        find /var/www/html -type d -exec chmod 775 {} \;
        # Make files group-readable and owner-writable
        find /var/www/html -type f -exec chmod 664 {} \;
        # Keep ownership as nobody but make group-accessible
        chown -R nobody:nobody /var/www/html
    else
        echo "[FTP] WordPress directory is empty, setting base permissions..."
        chown nobody:nobody /var/www/html
        chmod 775 /var/www/html
    fi
    
    echo "[FTP] WordPress directory configured for FTP access"
fi

echo "[FTP] Configuration complete. Starting vsftpd..."
echo "[FTP] FTP server will be available on port 21"
echo "[FTP] Use credentials: ftpuser / ftppass123 (or your custom FTP_USER)"
echo "[FTP] Home directory: /var/www/html (WordPress files)"
echo "[FTP] User UID: 1001, Group: nobody (for file access)"

# Create log file
touch /var/log/vsftpd.log
chmod 644 /var/log/vsftpd.log

# Start vsftpd in foreground
exec /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf