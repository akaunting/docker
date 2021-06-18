FROM php:7.4-fpm-alpine3.12

# Arguments defined in docker-compose.yml
ARG AKAUNTING_DOCKERFILE_VERSION=0.1
ARG SUPPORTED_LOCALES="en_US.UTF-8"

# Add Repositories
RUN rm -f /etc/apk/repositories &&\
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.12/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.12/community" >> /etc/apk/repositories

# Add Dependencies
RUN apk add --update --no-cache \
    gcc \
    g++ \
    make \
    python2 \
    supervisor \
    vim \
    bash \
    nodejs \
    npm \
    git \
    nginx

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Install PHP Extensions
RUN chmod +x /usr/local/bin/install-php-extensions && sync && \
    install-php-extensions gd zip intl imap xsl pgsql opcache bcmath mysqli pdo_mysql redis

# Configure Extension
RUN docker-php-ext-configure \
    opcache --enable-opcache

# Installing composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm -rf composer-setup.php

# Clear npm proxy
RUN npm config rm proxy
RUN npm config rm https-proxy

# Download Akaunting application
RUN mkdir -p /var/www/html
RUN cd /var/www/html && git clone https://github.com/akaunting/akaunting.git . && composer install && npm install && npm run dev

COPY files/akaunting-php-fpm-nginx-supervisord.sh /usr/local/bin/akaunting-php-fpm-nginx-supervisord.sh
COPY files/html /var/www/html

# Setup Working Dir
WORKDIR /var/www/html

EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/akaunting-php-fpm-nginx-supervisord.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
