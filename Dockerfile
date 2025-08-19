ARG PHP_VERSION=8.3.24
FROM dunglas/frankenphp:php${PHP_VERSION} AS main
ENV XDG_CONFIG_HOME=/tmp

# Look at here for all laravel php extensions
# https://laravel.com/docs/11.x/deployment#server-requirements

RUN apt-get update && apt-get install -y \
    curl \
    gpg \
    nano \
    procps \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    wget


# Install PHP extensions
RUN install-php-extensions pdo_mysql mbstring exif pcntl bcmath gd zip

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && sed -E -i -e 's/max_execution_time = 30/max_execution_time = 120/' $PHP_INI_DIR/php.ini \
    && sed -E -i -e 's/memory_limit = 128M/memory_limit = 512M/' $PHP_INI_DIR/php.ini \
    && sed -E -i -e 's/post_max_size = 8M/post_max_size = 500M/' $PHP_INI_DIR/php.ini \
    && sed -E -i -e 's/upload_max_filesize = 2M/upload_max_filesize = 500M/' $PHP_INI_DIR/php.ini \
    && sed -E -i -e 's/expose_php = On/expose_php = Off/' $PHP_INI_DIR/php.ini

# Create system user to run Composer and Artisan Commands
RUN useradd -g www-data -u 1000 ubuntu
RUN mkdir -p /home/ubuntu \
    && chown -R 1000:1000 /home/ubuntu

COPY Caddyfile /etc/caddy/Caddyfile
# Main
WORKDIR /var/www/html
EXPOSE 80
COPY --chown=33:33 entrypoint.sh.frankenphp /var/www/html/entrypoint.sh
COPY --chown=33:33 import.sh /import.sh
RUN chmod +x /var/www/html/entrypoint.sh
RUN chmod +x /import.sh
USER www-data
ENTRYPOINT [ "./entrypoint.sh" ]
