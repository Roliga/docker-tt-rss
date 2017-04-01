#!/bin/sh

updater='/usr/share/nginx/tt-rss/update_daemon2.php'

service php5-fpm start
service nginx start

su -s '/bin/sh' -c "$updater" www-data &
updaterPID=$!

while service php5-fpm status >/dev/null 2>&1 && \
	service nginx status >/dev/null 2>&1 && \
	kill -0 "$updaterPID" >/dev/null 2>&1; do

	sleep 10
done

kill "$updaterPID"
service nginx stop
service php5-fpm stop

#nginx -g 'daemon off;'
