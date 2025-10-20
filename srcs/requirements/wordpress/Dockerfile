# 1.1 Base image: Debian
FROM debian:bullseye

# 1.2 Install PHP, PHP-FPM, required extensions, and WP-CLI
RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-xml \
    php-mbstring \
    php-zip \
    curl \
    mariadb-client \
    less \
    wget \
    unzip \
    iputils-ping \
 && rm -rf /var/lib/apt/lists/*

# Install WP-CLI (WordPress Command Line Interface)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# 1.3 Download WordPress into container
WORKDIR /var/www/html

RUN wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz --strip-components=1 && \
    rm latest.tar.gz

# 1.4 Configure WordPress dynamically using environment variables
# We'll use an entrypoint script for that
COPY tools/wp-setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wp-setup.sh

# Adjust PHP-FPM to listen on port 9000 and be accessible from other containers
RUN sed -i 's|listen = /run/php/php7.4-fpm.sock|listen = 0.0.0.0:9000|' /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i 's|;clear_env = no|clear_env = no|' /etc/php/7.4/fpm/pool.d/www.conf
RUN mkdir -p /run/php

# Set proper ownership for WordPress files
RUN chown -R www-data:www-data /var/www/html

EXPOSE 9000

ENTRYPOINT ["wp-setup.sh"]
CMD ["php-fpm7.4", "-F", "-R"]
# ENTRYPOINT ["bash", "-c", "while true; do sleep 60; done"]
