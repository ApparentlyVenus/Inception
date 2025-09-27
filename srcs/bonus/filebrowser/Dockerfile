FROM alpine:3.18

# Use HTTP repositories to avoid SSL issues
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.18/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.18/community" >> /etc/apk/repositories && \
    apk update

# Install dependencies
RUN apk add --no-cache \
    wget \
    ca-certificates

# Download and install Filebrowser
RUN wget https://github.com/filebrowser/filebrowser/releases/download/v2.23.0/linux-amd64-filebrowser.tar.gz -O /tmp/filebrowser.tar.gz && \
    tar -xzf /tmp/filebrowser.tar.gz -C /usr/local/bin && \
    chmod +x /usr/local/bin/filebrowser && \
    rm /tmp/filebrowser.tar.gz

# Create filebrowser user and config directory
RUN adduser -D -s /bin/sh filebrowser && \
    mkdir -p /config && \
    chown filebrowser:filebrowser /config

# Switch to filebrowser user
USER filebrowser

# Expose port
EXPOSE 8080

# Start filebrowser with baseurl for subpath serving
CMD ["filebrowser", "--address", "0.0.0.0", "--port", "8080", "--root", "/var/www/html", "--database", "/config/filebrowser.db", "--baseurl", "/files"]