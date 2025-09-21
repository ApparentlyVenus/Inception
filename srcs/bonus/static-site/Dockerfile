FROM alpine:3.18

# Use HTTP repositories to avoid SSL issues
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.18/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.18/community" >> /etc/apk/repositories && \
    apk update

# Install nginx
RUN apk add --no-cache nginx

# Create web directory
RUN mkdir -p /var/www/html && \
    mkdir -p /run/nginx

# Copy static website files
COPY tools/index.html /var/www/html/
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Set permissions
RUN chown -R nginx:nginx /var/www/html

EXPOSE 8080

# Start nginx
CMD ["nginx", "-g", "daemon off;"]