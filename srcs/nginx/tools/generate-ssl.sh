#!/bin/sh

openssl genrsa -out /etc/nginx/certs/nginx.key 2048

openssl req -new -key /etc/nginx/certs/nginx.key -out /etc/nginx/certs/nginx.csr -subj "/C=US/ST=State/L=City/O=Organization/CN=${DOMAIN_NAME}"

openssl x509 -req -days 365 -in /etc/nginx/certs/nginx.csr -signkey /etc/nginx/certs/nginx.key -out /etc/nginx/certs/nginx.crt

chmod 600 /etc/nginx/certs/nginx.key
chmod 644 /etc/nginx/certs/nginx.crt

echo "SSL certificate generated for ${DOMAIN_NAME}"