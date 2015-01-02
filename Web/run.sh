#!/bin/bash

export DATABASE_URL="postgres://docker:docker@$DATABASE_POSTGRE_HOST:5432/docker"
export CELERY_BROKER_URL="redis://$CELERY_BROKER_REDIS_HOST:6379/1"

#add ports to nginx, which requires config file instead of env vars
curl -sLo /usr/local/bin/ep https://github.com/kreuzwerker/envplate/releases/download/v0.0.4/ep-linux && chmod +x /usr/local/bin/ep
ep /etc/nginx/nginx.conf

service nginx restart &&\
gunicorn cabot.wsgi:application --config gunicorn.conf --log-level info --log-file /var/log/gunicorn &\
celery worker -B -A cabot --loglevel=INFO --concurrency=4 -Ofair
