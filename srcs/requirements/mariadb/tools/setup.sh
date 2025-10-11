#!/bin/bash
set -e

# Default environment variables (if not set)
: "${MYSQL_ROOT_PASSWORD:=rootpassword}"
: "${MYSQL_DATABASE:=wordpress}"
: "${MYSQL_USER:=wp_user}"
: "${MYSQL_PASSWORD:=wp_pass}"
: "${MYSQL_ADMIN_USER:=admin}"
: "${MYSQL_ADMIN_PASS:=admin_pass}"

# Initialize MariaDB if needed
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[INFO] Initializing MariaDB database..."
    mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql
fi

# Start MariaDB in the background
echo "[INFO] Starting MariaDB..."
mysqld_safe --datadir=/var/lib/mysql &

# Wait for MariaDB to be ready
until mysqladmin ping >/dev/null 2>&1; do
    echo "[INFO] Waiting for MariaDB to start..."
    sleep 2
done

echo "[INFO] Creating database and users..."

# Run SQL commands
mysql -u root <<-EOSQL
    -- Create WordPress database
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

    -- Create regular WordPress user
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

    -- Create admin user
    CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASS}';
    GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_ADMIN_USER}'@'%' WITH GRANT OPTION;

    FLUSH PRIVILEGES;
EOSQL

echo "[INFO] MariaDB setup complete."

# Keep the container running
exec mysqld_safe --datadir=/var/lib/mysql

