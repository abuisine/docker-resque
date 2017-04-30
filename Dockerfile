FROM php:7.1

LABEL maintainer="Alexandre Buisine <alexandrejabuisine@gmail.com>"
LABEL version="3.0.0"

RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update \
 && apt-get install -yqq \
 	curl \
 	libcurl4-gnutls-dev \
 	vim-tiny \
	libpq5 \
 && apt-get -yqq clean \
 && rm -rf /var/lib/apt/lists/*

ENV PHP_REDIS_VERSION="3.1.2" IGBINARY_VERSION="2.0.1"

RUN docker-php-ext-install -j$(nproc) pdo_mysql \
 && docker-php-ext-install -j$(nproc) curl \
 && docker-php-ext-install -j$(nproc) pcntl \
 && docker-php-ext-install -j$(nproc) sockets \
 && pecl install igbinary-${IGBINARY_VERSION} \
 && docker-php-ext-enable igbinary \
 && pecl install xdebug \
 && docker-php-ext-enable xdebug

RUN mkdir /tmp/redis && curl -L https://github.com/phpredis/phpredis/archive/${PHP_REDIS_VERSION}.tar.gz | tar xvz -C /tmp/redis --strip-components=1 \
 && ( cd /tmp/redis && phpize && ./configure --with-php-config=/usr/local/bin/php-config --enable-redis-igbinary && make -j $(nproc) && make install ) \
 && rm -r /tmp/redis \
 && docker-php-ext-enable redis

COPY resources/php.ini /usr/local/etc/php/php.ini

STOPSIGNAL SIGQUIT

ENV SYMLINK_FOLDER="/var/cron/current"

ENTRYPOINT ["php", "/var/cron/current/resque/resque.php"]