FROM alpine:3.18

# Install MariaDB and required packages
RUN apk add --no-cache \
    mariadb \
    mariadb-client \
    mariadb-server-utils

# Create required directories and set permissions
# (mysql user/group already exists from mariadb package)
RUN mkdir -p /run/mysqld && \
    mkdir -p /var/lib/mysql && \
    mkdir -p /var/log/mysql && \
    chown -R mysql:mysql /run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql && \
    chown -R mysql:mysql /var/log/mysql

# Copy MariaDB configuration
COPY conf/50-server.cnf /etc/my.cnf.d/50-server.cnf

# Fix the default mariadb-server.cnf to allow networking
RUN sed -i 's/^skip-networking/#skip-networking/' /etc/my.cnf.d/mariadb-server.cnf && \
    sed -i 's/#bind-address=0.0.0.0/bind-address=0.0.0.0/' /etc/my.cnf.d/mariadb-server.cnf

# Copy and set up initialization script
COPY tools/init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# Expose MariaDB port
EXPOSE 3306

# Switch to mysql user and start the service
USER mysql
ENTRYPOINT ["init.sh"]