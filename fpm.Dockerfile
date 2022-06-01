FROM php:8.1-fpm

# Arguments defined in docker-compose.yml
ARG AKAUNTING_DOCKERFILE_VERSION=0.1
ARG SUPPORTED_LOCALES="en_US.UTF-8"

RUN apt-get update \
   && apt-get -y upgrade --no-install-recommends \
   && apt-get install -y \
   build-essential \
   imagemagick \
   libfreetype6-dev \
   libicu-dev \
   libjpeg62-turbo-dev \
   libjpeg-dev \
   libmcrypt-dev \
   libonig-dev \
   libpng-dev \
   libpq-dev \
   libssl-dev \
   libxml2-dev \
   libxrender1 \
   libzip-dev \
   locales \
   openssl \
   unzip \
   zip \
   zlib1g-dev \
   --no-install-recommends \
   && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN for locale in ${SUPPORTED_LOCALES}; do \
   sed -i 's/^# '"${locale}/${locale}/" /etc/locale.gen; done \
   && locale-gen

RUN docker-php-ext-configure gd \
   --with-freetype \
   --with-jpeg \
   && docker-php-ext-install -j$(nproc) \
   gd \
   bcmath \
   intl \
   mbstring \
   pcntl \
   pdo \
   pdo_mysql \
   zip

# Download Akaunting application
RUN mkdir -p /var/www/akaunting \
   && curl -Lo /tmp/akaunting.zip 'https://akaunting.com/download.php?version=latest&utm_source=docker&utm_campaign=developers' \
   && unzip /tmp/akaunting.zip -d /var/www/html \
   && rm -f /tmp/akaunting.zip

COPY files/akaunting-php-fpm.sh /usr/local/bin/akaunting-php-fpm.sh
COPY files/html /var/www/html

# Set working directory
WORKDIR /var/www/html

EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/akaunting-php-fpm.sh"]
CMD ["--start"]
