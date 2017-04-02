#!/bin/sh

# Path to tt-rss instance
ttrssPath='/usr/share/nginx/tt-rss/'

# Config setup output path. Mount this file when running in setup mode.
setupOutput='/config.php'

# Path to tt-rss feed updater to use. Either update.php --daemon or update_daemon2.php can be used.
updater="$ttrssPath/update_daemon2.php"

# Start the web server
service php5-fpm start
service nginx start

if [ "$SETUP" = 'true' ]; then
	echo "RUNNING IN SETUP MODE!" 1>&2

	# If we're using the nginx proxy, output a url for the setup address
	if [ -n "$VIRTUAL_HOST" ]; then
		echo "Configre tt-rss at http://$VIRTUAL_HOST/install/" 1>&2
	fi

	# Run until config file is generated
	while ! [ -e "$ttrssPath/config.php" ]; do
		sleep 1
	done

	echo "Config file found, saving.." 1>&2

	cp "$ttrssPath/config.php" "$setupOutput"

	echo "All done, goodbye!" 1>&2
else
	# Run updater as ww-data user
	su -s '/bin/sh' -c "$updater" www-data &
	updaterPID=$!

	# Check that all services are running every 10 seconds, and if not kill the whole container.
	while service php5-fpm status >/dev/null 2>&1 && \
		service nginx status >/dev/null 2>&1 && \
		kill -0 "$updaterPID" >/dev/null 2>&1; do

		sleep 10
	done

	# Stop updater
	kill "$updaterPID"

fi

# Stop webserver
service nginx stop
service php5-fpm stop
