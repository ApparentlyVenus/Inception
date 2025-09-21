FROM alpine:3.18

# Use HTTP repositories to avoid SSL issues
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.18/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.18/community" >> /etc/apk/repositories && \
    apk update

# Install Redis
RUN apk add --no-cache redis

# Create data directory and set permissions
# (redis user already exists from redis package)
RUN mkdir -p /data && \
    chown redis:redis /data

# Switch to redis user
USER redis

# Expose Redis port
EXPOSE 6379

# Start Redis server with protected mode disabled
CMD ["redis-server", "--bind", "0.0.0.0", "--port", "6379", "--dir", "/data", "--protected-mode", "no"]