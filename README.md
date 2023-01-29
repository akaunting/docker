# Akaunting Docker Image

You can pull the latest image with `docker pull docker.io/akaunting/akaunting:latest`

## Description

This repository defines how the official Akaunting images are built for Docker Hub.

Akaunting is online, open source and free accounting software built with modern technologies. Track your income and expenses with ease. For more information on Akaunting, please visit the [website](https://akaunting.com).

## Usage

```shell
git clone https://github.com/akaunting/docker
cd docker
cp env/db.env.example env/db.env
vi env/db.env # and set things
cp env/run.env.example env/run.env
vi env/run.env # and set things

AKAUNTING_SETUP=true docker-compose up -d
```

Then head to HTTP at port 8080 on the docker-compose host and finish configuring your Akaunting company through the interactive wizard.

After setup is complete, bring the containers down before bringing them back up without the setup variable.

```shell
docker-compose down
docker-compose up -d
```

> Please never use `AKAUNTING_SETUP=true` environment variable again after the first time use.

If you have a database cluster you can take advantage of the following environment variables:

```
# In env/run.env put:
DB_HOST_WRITE: "example-write"
DB_HOST_READ: "example-read"
```

You can use Redis with Akaunting for performance enhancement and scalability, if you have a Redis you can take advantage of the following environment variables:

```
# In env/run.env put:
REDIS_HOST: "example-redis"
# Switch cache driver to redis
CACHE_DRIVER: "redis"
# Switch session driver to redis
SESSION_DRIVER: "redis"
# Switch queue driver to redis
QUEUE_CONNECTION: "redis"
```

## Extra ways to explore containerized Akaunting!
This repository contains extra compose and other files that allows you to run Akaunting in different setups like using FPM and NGINX and here is the most important commands that you may need:

```shell
# Run Akaunting setup that checks for volume files before copying them.
AKAUNTING_SETUP=true docker-compose -f v-docker-compose.yml up --build

# Run Akaunting with FPM on Debian and use Nginx as external proxy
AKAUNTING_SETUP=true docker-compose -f fpm-docker-compose.yml up --build

# Run Akaunting using FPM on Alpine and using Nginx as external proxy
AKAUNTING_SETUP=true docker-compose -f fpm-docker-compose.yml -f fpm-alpine-docker-compose.yml up --build

# Run Akaunting using FPM on Alpine and using Nginx as internal proxy
AKAUNTING_SETUP=true docker-compose -f fpm-alpine-nginx-docker-compose.yml up --build

# Download Akaunting using git and install composer and npm and run Akaunting using FPM on Alpine and using Nginx as internal proxy
AKAUNTING_SETUP=true docker-compose -f fpm-alpine-nginx-docker-compose.yml -f fpm-alpine-nginx-composer-docker-compose.yml up --build

# Download Akaunting using git and install composer and npm and run Akaunting using FPM on Alpine and using Nginx as internal proxy and supervisor to manage the queues
AKAUNTING_SETUP=true docker-compose -f fpm-alpine-nginx-docker-compose.yml -f fpm-alpine-nginx-composer-supervisor-docker-compose.yml up --build
```

## License

Akaunting is released under the [GPLv3 license](LICENSE.txt).
