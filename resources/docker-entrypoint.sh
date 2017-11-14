#!/bin/bash
set -eo pipefail

if [ "${XDEBUG_ENABLED}" == "false" ]
then
	rm /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini || true
fi

/usr/local/bin/ep -v /usr/local/etc/php/php.ini

exec $@