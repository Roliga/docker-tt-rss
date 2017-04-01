#!/bin/sh

# Path to tt-rss feed updater to use. Either update.php --daemon or update_daemon2.php can be used.
updater='/usr/share/nginx/tt-rss/update_daemon2.php'

# Start the web server
service php5-fpm start
service nginx start

# Run updater as ww-data user
su -s '/bin/sh' -c "$updater" www-data &
updaterPID=$!

# Check that all services are running every 10 seconds, and if not kill the whole container.
while service php5-fpm status >/dev/null 2>&1 && \
	service nginx status >/dev/null 2>&1 && \
	kill -0 "$updaterPID" >/dev/null 2>&1; do

	sleep 10
done

# Stop all processes before exiting
kill "$updaterPID"
service nginx stop
service php5-fpm stop
