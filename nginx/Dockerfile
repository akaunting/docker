FROM nginx:alpine

ENV AKAUNTING_VERSION 2.0.13

RUN apk update && apk add --no-progress -q wget unzip

RUN wget https://github.com/akaunting/akaunting/releases/download/${AKAUNTING_VERSION}/Akaunting_${AKAUNTING_VERSION}-Stable.zip
RUN mkdir -p /var/www/akaunting
RUN unzip Akaunting_${AKAUNTING_VERSION}-Stable.zip -d /var/www/akaunting
RUN rm Akaunting_${AKAUNTING_VERSION}-Stable.zip

RUN chmod -R 777 /var/www/akaunting
