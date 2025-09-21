FROM alpine:3.18

# Use HTTP repositories to avoid SSL issues
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.18/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.18/community" >> /etc/apk/repositories && \
    apk update

# Install PHP-FPM and required extensions for Adminer
RUN apk add --no-cache \
    php81-fpm \
    php81-pdo_mysql \
    php81-mysqli \
    php81-json \
    php81-session \
    php81-mbstring \
    wget

# Create web directory and PHP-FPM run directory
RUN mkdir -p /var/www/html && \
    mkdir -p /run/php

# Download Adminer
RUN wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -O /var/www/html/index.php

# Set permissions
RUN chown -R nobody:nobody /var/www/html

# Copy PHP-FPM configuration
COPY conf/www.conf /etc/php81/php-fpm.d/www.conf

WORKDIR /var/www/html

EXPOSE 9001

# Start PHP-FPM
CMD ["php-fpm81", "-F"]