FROM php:8.3-apache

RUN docker-php-ext-install pdo_mysql \
    && mkdir -p /var/lib/php/sessions \
    && chown www-data:www-data /var/lib/php/sessions \
    && chmod 1733 /var/lib/php/sessions \
    && printf 'session.save_path = "/var/lib/php/sessions"\n' > /usr/local/etc/php/conf.d/sigeru-sessions.ini

COPY docker/apache.conf /etc/apache2/sites-available/000-default.conf
COPY public/ /var/www/html/public/
COPY app/ /var/www/html/app/
