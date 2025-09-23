FROM alpine:3.18

# Use HTTP repositories to avoid SSL issues
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.18/main" > /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.18/community" >> /etc/apk/repositories && \
    apk update

# Install vsftpd (Very Secure FTP Daemon)
RUN apk add --no-cache \
    vsftpd \
    openssl

# Create FTP user and directories
RUN adduser -D -s /bin/sh ftpuser && \
    echo "ftpuser:ftppass" | chpasswd && \
    mkdir -p /var/ftp/ftpuser && \
    chown ftpuser:ftpuser /var/ftp/ftpuser && \
    mkdir -p /var/log/vsftpd

# Create SSL certificate for secure FTP
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/vsftpd.pem \
    -out /etc/ssl/private/vsftpd.pem \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Copy configuration
COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf

# Copy startup script
COPY tools/ftp-setup.sh /usr/local/bin/ftp-setup.sh
RUN chmod +x /usr/local/bin/ftp-setup.sh

# Expose FTP ports
# 21 = control connection, 21000-21010 = passive data connections
EXPOSE 21 21000-21010

ENTRYPOINT ["ftp-setup.sh"]