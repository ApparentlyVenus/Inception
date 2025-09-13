FROM alpine:3.18

RUN apk add --no-cache \
    nginx \
    openssl

RUN mkdir -p /var/www/html && \
    mkdir -p /etc/nginx/certs && \
    mkdir -p /run/nginx

COPY conf/nginx.conf /etc/nginx/nginx.conf

COPY tools/generate-ssl.sh /usr/local/bin
RUN chmod +x /usr/local/bin/generate-ssl.sh

RUN /usr/local/bin/generate-ssl.sh

EXPOSE 443

ENTRYPOINT [ "nginx", "-g", "daemon off;" ]