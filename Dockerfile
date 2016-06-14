################################
# Dockerfile to build PHP image
################################
# Base image
FROM php:latest

# Author: MobileSnapp Inc.
MAINTAINER MobileSnapp <support@mobilesnapp.com>

# Install PHP extensions and PECL modules.
RUN buildDeps=" \
        libbz2-dev \
        libmysqlclient-dev \
    " \
    runtimeDeps=" \
        curl \
        git \
        libfreetype6-dev \
        libicu-dev \
        libjpeg-dev \
        libmcrypt-dev \
        libpng12-dev \
        libpq-dev \
    " \
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y $buildDeps $runtimeDeps \
    && docker-php-ext-install bz2 calendar iconv intl mbstring mcrypt mysqli pdo_mysql pdo_pgsql pgsql zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && apt-get purge -y --auto-remove $buildDeps \
    && rm -r /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    libmemcached-dev \
    --no-install-recommends \
    && rm -r /var/lib/apt/lists/*

# Install extensions using the helper script provided by the base image
RUN docker-php-ext-install \
    pdo_mysql \
    pdo_pgsql

# Install xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Install Composer.
ENV COMPOSER_HOME /root/composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ENV PATH $COMPOSER_HOME/vendor/bin:$PATH

RUN usermod -u 1000 www-data

WORKDIR /var/www/site

EXPOSE 9000

