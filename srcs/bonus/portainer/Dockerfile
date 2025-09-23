FROM alpine:3.18

# Use HTTP repositories to avoid SSL issues
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.18/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.18/community" >> /etc/apk/repositories && \
    apk update

# Install dependencies
RUN apk add --no-cache \
    wget \
    ca-certificates

# Create portainer user and directories
RUN adduser -D -u 1000 -s /bin/sh portainer && \
    mkdir -p /data && \
    chown -R portainer:portainer /data

# Download Portainer binary
RUN wget https://github.com/portainer/portainer/releases/download/2.19.4/portainer-2.19.4-linux-amd64.tar.gz -O /tmp/portainer.tar.gz && \
    tar -xzf /tmp/portainer.tar.gz -C /tmp && \
    mv /tmp/portainer/portainer /usr/local/bin/ && \
    chmod +x /usr/local/bin/portainer && \
    rm -rf /tmp/portainer*

# Switch to portainer user
USER portainer

# Expose Portainer port
EXPOSE 9000

# Start Portainer
CMD ["portainer", "--data", "/data", "--host", "0.0.0.0:9000"]