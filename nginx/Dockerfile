FROM nginx:alpine

RUN apk update && apk add --no-progress -q wget unzip

RUN wget -O akaunting.zip https://akaunting.com/download.php?version=latest&utm_source=docker
RUN mkdir -p /var/www/akaunting
RUN unzip akaunting.zip -d /var/www/akaunting
RUN rm akaunting.zip

RUN chmod -R 777 /var/www/akaunting
