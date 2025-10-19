#!/bin/bash
set -e

if [ ! getent group $WORDPRESS_DB_USER > /dev/null 2>&1 ]; then
	addgroup -S $WORDPRESS_DB_USER;
fi

if [ ! getent passwd $WORDPRESS_DB_USER > /dev/null 2>&1 ]; then
	adduser -S -D -H -s $group /sbin/nologin -g $WORDPRESS_DB_USER $WORDPRESS_DB_USER;
fi

chown -R $WORDPRESS_DB_USER:$WORDPRESS_DB_USER /var/www/html
# Change to WordPress directory
cd /var/www/html

# Wait for MariaDB to be ready
echo "⏳ Waiting for MariaDB..."
until mysqladmin ping -h"$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --silent; do
    echo "⏳ MariaDB is unavailable - waiting..."
    sleep 2
done
echo "✅ MariaDB is ready!"


# Generate wp-config.php if it doesn’t exist
if [ ! -f wp-config.php ]; then
    echo "🧩 Setting up wp-config.php..."
    wp config create \
        --allow-root \
        --dbname="$WORDPRESS_DB_NAME" \
        --dbuser="$WORDPRESS_DB_USER" \
        --dbpass="$WORDPRESS_DB_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST" \
        --path=/var/www/html
fi

echo "HOLAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA :D"

# Run WordPress installation if not already installed
if ! wp core is-installed --allow-root; then
    echo "🚀 Installing WordPress..."
    wp core install \
        --allow-root \
        --url="$WORDPRESS_URL" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL"
fi

echo "✅ WordPress is ready!"
exec "$@"

