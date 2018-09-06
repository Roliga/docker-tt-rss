FROM debian:latest

# Install nginx
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install git nginx php7.0 php7.0-pgsql php7.0-fpm php7.0-curl php7.0-cli php7.0-intl php7.0-mbstring php-fdomdocument

# Install tt-rss
RUN git clone https://tt-rss.org/git/tt-rss.git /usr/share/nginx/tt-rss && \
    chown -R www-data:www-data \
        /usr/share/nginx/tt-rss/cache \
        /usr/share/nginx/tt-rss/lock \
        /usr/share/nginx/tt-rss/feed-icons

# Install feediron plugin
RUN git clone git://github.com/m42e/ttrss_plugin-feediron.git /usr/share/nginx/tt-rss/plugins/feediron

# Install feedly theme
RUN git clone https://github.com/levito/tt-rss-feedly-theme.git /tmp/feedly-theme && \
    cp -r /tmp/feedly-theme/feedly.css \
        /tmp/feedly-theme/feedly-nightly.css \
        /tmp/feedly-theme/feedly \
	/usr/share/nginx/tt-rss/themes/ && \
    rm -rf /tmp/feedly-theme


COPY nginx-vhost.conf /etc/nginx/conf.d/
RUN rm /etc/nginx/sites-enabled/default

# Install startup script
COPY run-tt-rss.sh /usr/local/bin/

# expose default port
EXPOSE 80

CMD [ "run-tt-rss.sh" ]
