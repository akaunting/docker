# Akaunting Docker Image

You can pull the latest image with `docker pull docker.io/akaunting/akaunting:latest`

## Description

This repository defines how the official Akaunting images are built for Docker Hub.

Akaunting is online, open source and free accounting software built with modern technologies. Track your income and expenses with ease. For more information on Akaunting, please visit the [website](https://akaunting.com).

## Prerequisites

1. docker-compose, or the knowhow to use docker or podman to run these images.
1. You'll need to use some other reverse proxy for TLS termination. HAProxy, Nginx, or Apache work fine and have integrations with [Let'sEncrypt](https://letsencrypt.org/) that let you request wildcard certificates. See [Reverse proxying for TLS termination](#reverse-proxying-for-tls-termination) for more information. Reverse proxies are all trusted in these images to support use cases like [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/).
1. Your own cache, if you need to scale to lots of users. Memcached and Redis are popular choices. See the [configuration for cache](https://github.com/akaunting/akaunting/blob/master/config/cache.php) and [redis](https://github.com/akaunting/akaunting/blob/master/config/database.php#L128) if necessary. You can provide the variables for configuration via [run.env](env/run.env.example).

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

Then head to HTTP at port 8080 on the docker-compose hostand finish configuring your Akaunting company through the interactive wizard.

After setup is complete, bring the containers down before bringing them back up without the setup variable.

```shell
docker-compose down -v
docker-compose up -d
```

Included is a [watchtower](https://containrrr.dev/watchtower/) container. This will automatically pull updates for the [MariaDB](https://hub.docker.com/_/mariadb) and [Akaunting](https://hub.docker.com/akaunting/akaunting) images daily, restarting the containers with the new images when there has been an update.

## Backup and restore

You could use something like the following commands to make backups for your deployment:

```shell
mkdir -p ~/backups
for volume in akaunting-data akaunting-db; do
    docker run --rm -v $volume:/volume -v ~/backups:/backups alpine tar cvzf /backups/$volume-$(date +%Y-%m-%d).tgz -C /volume ./
done
```

In order to restore those backups, you would run something like:

```shell
backup=2021-01-26 # you should select the backup you want to restore here
for volume in akaunting-data akaunting-db; do
    docker run --rm -v $volume:/volume -v ~/backups:/backups alpine sh -c "rm -rf /volume/* /volume/..?* /volume/.[!.]* ; tar xvzf /backups/$volume-$backup.tgz -C /volume"
done
```

## A note on upgrades

The upgrade between 2.0.26 and 2.1.0 broke some things in existing deployments due to a Laravel version migration in Akaunting. In order to fix this, you could have run something like the following:

```shell
docker exec -it akaunting bash
```

Then, inside the container, the following:

```shell
php artisan view:clear
```

Future version migrations might require something like:

```shell
php artisan migrate --force
```

Application upgrade/migration logic is not baked into this application image. An upgrade between versions that requires intervention would best be encapsulated in something like a [Kubernetes Operator](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/), rather than adding to the complexity of the application image.

If you use these images in production, it is recommended to have a testing environment that draws automatic updates and exists so that you can validate the steps required to migrate between versions. Your production deployment should use pinned version tags, which are tagged based on the Akaunting release. Migrating your production version would then require manual intervention and enable you to take the manual steps necessary to complete the migration.

## Reverse proxying for TLS termination

No configuration has been provided for TLS termination. The "right" TLS termination strategy and load balancing setup is highly subjective and depends very much on the rest of your environment. The container image accepts connections from any proxy, and recognizes the host from HTTP requests via the APP_URL environment variable.

Googling "letsencrypt haproxy" returns with [a](https://serversforhackers.com/c/letsencrypt-with-haproxy) [number](https://gridscale.io/en/community/tutorials/haproxy-ssl/) [of](https://kevinbentlage.nl/blog/lets-encrypt-with-haproxy/) [articles](https://cheppers.com/how-https-haproxy-and-letsencrypt) with decent instructions on how to set up HAProxy and certbot to automatically renew certificates served. Some extra keywords, like [wildcard](https://nicklang.com/posts/letsencrypt-a-wildcard-cert-for-haproxy-to-use-in-docker-swarm), give enough extra information to layer that into your configuration. If nginx makes more sense for your environment, an nginx configuration that stitches together the elements of [load balancing](http://nginx.org/en/docs/http/load_balancing.html), [reverse proxying](https://timothy-quinn.com/using-nginx-as-a-reverse-proxy-for-multiple-sites/), and [Let'sEncrypt](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04) can meet the same need. So can Apache, or a number of other webservers. The world is your oyster.

A robust TLS termination and load-balancing setup should outperform, and be easier to maintain than, many little nginx containers running with their own certificate lifecycles, even if they're automated. Running Akaunting in a container makes the most sense if you're running lots of services on fewer hosts, and for that use case a load-balancing reverse proxy for TLS termination might make more sense. Or it might not. Now you get to choose.

## Languages

Right now, the only built language is US English. If you would like more supported locales to be built into the container image, please [open an issue](https://github.com/akaunting/docker/issues).

## License

Akaunting is released under the [GPLv3 license](LICENSE.txt).
