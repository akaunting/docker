FROM php:8.2.35-apache

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

RUN pecl install redis \
    && docker-php-ext-enable redis

RUN mkdir -p /var/www/akaunting \
    && VERSION=$(curl -fsSL https://api.github.com/repos/akaunting/akaunting/releases/latest \
        | grep '"tag_name"' \
        | head -1 \
        | cut -d '"' -f4) \
    && echo "Downloading Akaunting ${VERSION}" \
    && curl -fLo /tmp/akaunting.zip \
        "https://github.com/akaunting/akaunting/releases/download/${VERSION}/Akaunting_${VERSION#v}-Stable.zip" \
    && unzip /tmp/akaunting.zip -d /var/www/html \
    && rm -f /tmp/akaunting.zip

COPY files/akaunting.sh /usr/local/bin/akaunting.sh
COPY files/html /var/www/html

ENTRYPOINT ["/usr/local/bin/akaunting.sh"]
CMD ["--start"]
