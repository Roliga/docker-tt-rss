FROM debian:latest

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install git nginx php5 php5-pgsql php5-fpm php-apc php5-curl php5-cli php5-intl

RUN git clone https://tt-rss.org/git/tt-rss.git /usr/share/nginx/tt-rss && \
    chown -R www-data:www-data \
        /usr/share/nginx/tt-rss/cache \
        /usr/share/nginx/tt-rss/lock \
        /usr/share/nginx/tt-rss/feed-icons

COPY run-tt-rss.sh /usr/local/bin/
COPY nginx-vhost.conf /etc/nginx/conf.d/

RUN rm /etc/nginx/sites-enabled/default

# expose default port
EXPOSE 80

CMD [ "run-tt-rss.sh" ]
