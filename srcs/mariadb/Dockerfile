FROM alpine:3.18

# Install MariaDB
RUN apk add --no-cache \
    mariadb \
    mariadb-client \
    mariadb-server-utils

# Copy initialization script
COPY tools/init.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init.sh

# Create MariaDB directories
RUN mkdir -p /run/mysqld && \
    chown mysql:mysql /run/mysqld

# Expose MariaDB port
EXPOSE 3306

# Run initialization and start MariaDB
ENTRYPOINT ["init.sh"]