FROM alpine:3.18

# Use HTTP repositories to avoid SSL issues
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.18/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.18/community" >> /etc/apk/repositories && \
    apk update

# Install PHP-FPM and required extensions
RUN apk add --no-cache \
    php81-fpm \
    php81-pdo_mysql \
    php81-mysqli \
    php81-json \
    php81-curl \
    php81-dom \
    php81-exif \
    php81-fileinfo \
    php81-mbstring \
    php81-openssl \
    php81-xml \
    php81-zip \
    php81-redis \
    php81-session \
    php81-iconv \
    php81-gd \
    php81-cli \
    php81-phar \
    php81-pecl-redis \
    wget \
    unzip \
    netcat-openbsd

# Download WP-CLI during build
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

# Create required directories (use root ownership for now)
RUN mkdir -p /var/www/html && \
    mkdir -p /run/php

# Copy configuration files
COPY conf/www.conf /etc/php81/php-fpm.d/www.conf
COPY conf/php.ini /etc/php81/php.ini

# Copy setup script
COPY tools/wordpress-setup.sh /usr/local/bin/wordpress-setup.sh
RUN chmod +x /usr/local/bin/wordpress-setup.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["wordpress-setup.sh"]