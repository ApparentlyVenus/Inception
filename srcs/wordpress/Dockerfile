FROM alpine:3.18

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
    wget \
    unzip \
    netcat-openbsd

RUN mkdir -p /var/www/html && \
    mkdir -p /run/php

COPY conf/www.conf /ect/php81/php-fpm.d/www.conf
COPY conf/php.ini /etc/php81/php.ini

COPY tools/wordpress-setup.sh /usr/local/bin
RUN chmod +x /usr/local/bin/wordpress-setup.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT [ "wordpress-setup.sh" ]