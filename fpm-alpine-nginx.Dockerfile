FROM php:8.1-fpm-alpine3.15

# Arguments defined in docker-compose.yml
ARG AKAUNTING_DOCKERFILE_VERSION=0.1
ARG SUPPORTED_LOCALES="en_US.UTF-8"

# Add Repositories
RUN rm -f /etc/apk/repositories &&\
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.15/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.15/community" >> /etc/apk/repositories

# Add Dependencies
RUN apk add --update --no-cache \
    nano \
    bash \
    nginx

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install PHP Extensions
RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions gd zip intl imap xsl pgsql opcache bcmath mysqli pdo_mysql

# Configure Extension
RUN docker-php-ext-configure \
    opcache --enable-opcache

# Download Akaunting application
RUN mkdir -p /var/www/akaunting \
    && curl -Lo /tmp/akaunting.zip 'https://akaunting.com/download.php?version=latest&utm_source=docker&utm_campaign=developers' \
    && unzip /tmp/akaunting.zip -d /var/www/html \
    && rm -f /tmp/akaunting.zip

COPY files/akaunting-php-fpm-nginx.sh /usr/local/bin/akaunting-php-fpm-nginx.sh
COPY files/html /var/www/html

# Setup Working Dir
WORKDIR /var/www/html

EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/akaunting-php-fpm-nginx.sh"]
CMD ["--start"]