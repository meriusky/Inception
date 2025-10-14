#!/bin/bash
set -e

# Wait for MariaDB to be ready
echo "⏳ Waiting for MariaDB..."
until mysqladmin ping -h"$WORDPRESS_DB_HOST" --silent; do
    sleep 1
done

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

