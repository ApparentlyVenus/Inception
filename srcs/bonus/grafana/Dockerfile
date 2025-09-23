FROM alpine:3.18

# Use HTTP repositories to avoid SSL issues
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.18/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.18/community" >> /etc/apk/repositories && \
    apk update

# Install dependencies
RUN apk add --no-cache \
    wget \
    ca-certificates \
    libc6-compat \
    fontconfig

# Create grafana user
RUN addgroup -g 472 -S grafana && \
    adduser -D -u 472 -S -G grafana grafana

# Download and install Grafana
RUN wget https://dl.grafana.com/oss/release/grafana-9.5.15.linux-amd64.tar.gz -O /tmp/grafana.tar.gz && \
    tar -xzf /tmp/grafana.tar.gz -C /opt && \
    ls -la /opt && \
    mv /opt/grafana-* /opt/grafana && \
    rm /tmp/grafana.tar.gz

# Set up directories and permissions
RUN mkdir -p /var/lib/grafana/dashboards /var/lib/grafana/plugins /var/log/grafana && \
    chown -R grafana:grafana /opt/grafana /var/lib/grafana /var/log/grafana

# Copy configuration
COPY conf/grafana.ini /opt/grafana/conf/grafana.ini

# Switch to grafana user
USER grafana

# Expose Grafana port
EXPOSE 3000

WORKDIR /opt/grafana

# Start Grafana
CMD ["./bin/grafana-server", "--config=/opt/grafana/conf/grafana.ini"]