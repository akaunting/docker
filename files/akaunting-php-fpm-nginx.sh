#!/bin/bash -e

do_start=
do_shell=
do_setup=

while [ $# -gt 0 ]; do
    case "$1" in
        --start)
            do_start=true
            ;;
        --shell)
            do_start=false
            do_shell=true
            ;;
        --setup)
            do_setup=true
            do_start=true
            ;;
    esac
    shift
done

mkdir -p storage/framework/{sessions,views,cache}
mkdir -p storage/app/uploads

if [ "$do_setup" -o "$AKAUNTING_SETUP" == "true" ]; then
    retry_for=30
    retry_interval=5
    while sleep $retry_interval; do
        if php artisan install \
            --db-host=$DB_HOST \
            --db-port=$DB_PORT \
            --db-name=$DB_DATABASE \
            --db-username=$DB_USERNAME \
            "--db-password=$DB_PASSWORD" \
            --db-prefix=$DB_PREFIX \
            "--company-name=$COMPANY_NAME" \
            "--company-email=$COMPANY_EMAIL" \
            "--admin-email=$ADMIN_EMAIL" \
            "--admin-password=$ADMIN_PASSWORD" \
            "--locale=$LOCALE" --no-interaction; then break
        else
            if [ $retry_for -le 0 ]; then
                echo "Unable to find database!" >&2
                exit 1
            fi
            (( retry_for -= retry_interval ))
        fi
    done
else
    unset COMPANY_NAME COMPANY_EMAIL ADMIN_EMAIL ADMIN_PASSWORD
fi

chmod -R u=rwX,g=rX,o=rX /var/www/html
chown -R www-data:root /var/www/html

if [ "$do_start" ]; then
    php-fpm -D
    nginx -g "daemon off;"
elif [ "$do_shell" ]; then
    exec /bin/bash -li
fi
