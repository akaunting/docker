FROM php:8.2.35-fpm-alpine3.24

# Arguments defined in docker-compose.yml
ARG AKAUNTING_DOCKERFILE_VERSION=0.1
ARG SUPPORTED_LOCALES="en_US.UTF-8"

# Add Repositories
RUN rm -f /etc/apk/repositories &&\
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.24/main" >> /etc/apk/repositories && \
    echo "http://dl-cdn.alpinelinux.org/alpine/v3.24/community" >> /etc/apk/repositories

# Add Dependencies
RUN apk add --update --no-cache \
    gcc \
    g++ \
    make \
    python3 \
    supervisor \
    vim \
    bash \
    git \
    nginx

# Add Node.js 20 (Akaunting requires node >=18 <21 and node-sass does not build on the Node.js 24 shipped by Alpine 3.24)
COPY --from=node:20.20.2-alpine3.23 /usr/local/bin/node /usr/local/bin/node
COPY --from=node:20.20.2-alpine3.23 /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

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

# Setup Working Dir
WORKDIR /var/www/html

RUN git clone https://github.com/akaunting/akaunting.git .
RUN chown -R www-data:www-data /var/www/html
USER www-data
RUN composer prod
RUN npm install
RUN npm run prod

COPY files/akaunting-php-fpm-nginx-supervisord.sh /usr/local/bin/akaunting-php-fpm-nginx-supervisord.sh
COPY files/html /var/www/html

USER root

EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/akaunting-php-fpm-nginx-supervisord.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
