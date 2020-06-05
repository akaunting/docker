FROM nginx:alpine

RUN apk update && apk add --no-progress -q wget unzip

RUN wget -O akaunting.zip "https://akaunting.com/download.php?version=latest&utm_source=docker&utm_campaign=developers"
RUN mkdir -p /var/www/akaunting
RUN unzip akaunting.zip -d /var/www/akaunting
RUN rm akaunting.zip

RUN find /var/www/akaunting/ -type d -exec chmod 755 {} \;
RUN find /var/www/akaunting/ -type f -exec chmod 644 {} \;
