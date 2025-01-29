FROM php:8.3-apache

RUN apt update && \
    apt install cron

RUN mkdir -p /var/www/glpi/public
COPY 999-glpi.conf /etc/apache2/sites-available/999-glpi.conf
RUN a2enmod rewrite
RUN a2dissite 000-default
RUN a2ensite 999-glpi

WORKDIR /var/www/glpi

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY ./glpi.ini "$PHP_INI_DIR/conf.d/glpi.ini"

RUN curl -sSLf \
        -o /usr/local/bin/install-php-extensions \
        https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions && \
    chmod +x /usr/local/bin/install-php-extensions

RUN install-php-extensions gd intl mysqli
RUN install-php-extensions bz2 zip exif ldap openssl opcache

COPY ./glpi .
COPY ./downstream.php /var/www/glpi/inc/downstream.php

RUN mv ./config /etc/glpi && \
    mv ./files /var/lib/glpi && \
    mv /var/lib/glpi/_log /var/log/glpi

COPY ./local_define.php /etc/glpi/local_define.php

RUN chown www-data:www-data /etc/glpi -R && \
    chown www-data:www-data /var/lib/glpi -R && \
    chown www-data:www-data /var/log/glpi -R && \
    chown www-data:www-data /var/www/glpi/marketplace -Rf

RUN find /var/www/glpi/ -type f -exec chmod 0644 {} \; && \
    find /var/www/glpi/ -type d -exec chmod 0755 {} \; && \
    find /etc/glpi -type f -exec chmod 0644 {} \; && \
    find /etc/glpi -type d -exec chmod 0755 {} \; && \
    find /var/lib/glpi -type f -exec chmod 0644 {} \; && \
    find /var/lib/glpi -type d -exec chmod 0755 {} \; && \
    find /var/log/glpi -type f -exec chmod 0644 {} \; && \
    find /var/log/glpi -type d -exec chmod 0755 {} \;