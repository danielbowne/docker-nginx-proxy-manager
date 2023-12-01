# nginx-proxy-manager Dockerfile
#
# https://github.com/jlesage/docker-nginx-proxy-manager
#

# Pull base image.
FROM alpine:3.16

# Define software versions.
ARG NGINX_PROXY_MANAGER_VERSION=2.10.4

# Define environment variables.
ENV DOCKER_IMAGE_NAME=jlesage/nginx-proxy-manager

# Define working directory.
WORKDIR /tmp

# Install dependencies.
RUN apk add --no-cache \
        nginx \
        nodejs \
        npm \
        curl \
        openssl \
        apache2-utils \
        bash \
        pcre \
        luajit \
    && npm install -g pm2

# Add Nginx Proxy Manager source.
ADD https://github.com/jc21/nginx-proxy-manager/archive/v${NGINX_PROXY_MANAGER_VERSION}.tar.gz /tmp/nginx-proxy-manager.tar.gz

# Install and configure Nginx Proxy Manager.
RUN tar xzf nginx-proxy-manager.tar.gz \
    && mv nginx-proxy-manager-* nginx-proxy-manager \
    && cd nginx-proxy-manager \
    && npm install \
    && npm run build \
    && npm prune --production

# Cleanup.
RUN rm -rf /tmp/*

# Set internal environment variables.
ENV APP_NAME="Nginx Proxy Manager" \
    APP_VERSION="$NGINX_PROXY_MANAGER_VERSION"

# Expose ports.
#   - 80: HTTP traffic
#   - 443: HTTPS traffic
#   - 8181: Management web interface
EXPOSE 80 443 8181

# Metadata.
LABEL org.label-schema.name="nginx-proxy-manager" \
      org.label-schema.description="Docker container for Nginx Proxy Manager." \
      org.label-schema.version="unknown" \
      org.label-schema.vcs-url="https://github.com/danielbowne/docker-nginx-proxy-manager" \
      org.label-schema.schema-version="1.0"

# Set entrypoint and command.
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]