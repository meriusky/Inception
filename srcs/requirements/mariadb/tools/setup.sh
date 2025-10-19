#!/usr/bin/env bash
set -e

# Minimal settings
DATADIR="/home/mysqluser/data"
OSUSER="mysqluser"
BIND="0.0.0.0"
MARKER="$DATADIR/.initialized"

# Ensure dirs and ownership
mkdir -p /run/mysqld "$DATADIR"
chown -R "$OSUSER:$OSUSER" /run/mysqld "$DATADIR"

# Initialize MariaDB data directory if empty 
if [ ! -d "$DATADIR/mysql" ]; then
  mariadb-install-db --user="$OSUSER" --datadir="$DATADIR" 
fi

# Only run bootstrap SQL once
#INIT_SQL="/docker-entrypoint-initdb.d/init.sql"  # <- change here
INIT_SQL=""
if [ ! -f "$MARKER" ]; then 
  INIT_SQL="/tmp/init.sql"
  : > "$INIT_SQL"

  # 1) Set root password if provided
  if [ -n "${MYSQL_ROOT_PASSWORD:-}" ]; then
    echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" >> "$INIT_SQL"
   # echo "FLUSH PRIVILEGES;" >> "$INIT_SQL" #cambio
  fi

  # 2) Create admin user if both admin vars exist (supporting the provided name; pass var typo handled)
  ADMIN_USER="${MYSQL_ADMIN_USER:-}"
  ADMIN_PASS="${MYSQL_ADMIN_PASS:-}"
  if [ -n "$ADMIN_USER" ] && [ -n "$ADMIN_PASS" ]; then
    echo "CREATE USER IF NOT EXISTS '${ADMIN_USER}'@'localhost' IDENTIFIED BY '${ADMIN_PASS}';" >> "$INIT_SQL"
    echo "GRANT ALL PRIVILEGES ON *.* TO '${ADMIN_USER}'@'localhost' WITH GRANT OPTION;" >> "$INIT_SQL"
    echo "CREATE USER IF NOT EXISTS '${ADMIN_USER}'@'%' IDENTIFIED BY '${ADMIN_PASS}';" >> "$INIT_SQL"
    echo "GRANT ALL PRIVILEGES ON *.* TO '${ADMIN_USER}'@'%' WITH GRANT OPTION;" >> "$INIT_SQL"
  fi

  # 3) Create database and normal user if vars exist
  if [ -n "${MYSQL_DATABASE:-}" ]; then
    echo "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" >> "$INIT_SQL"
  fi
  if [ -n "${MYSQL_USER:-}" ] && [ -n "${MYSQL_PASSWORD:-}" ]; then
    echo "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';" >> "$INIT_SQL"
    if [ -n "${MYSQL_DATABASE:-}" ]; then
      echo "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';" >> "$INIT_SQL"
    fi
  #  echo "FLUSH PRIVILEGES;" >> "$INIT_SQL" #cambio
  fi
  echo "FLUSH PRIVILEGES;" >> "$INIT_SQL" #cambio: anyadido

  # Mark as initialized so this block is skipped on future container starts
  touch "$MARKER"
  chown "$OSUSER:$OSUSER" "$INIT_SQL"
fi

# Start server (one-time SQL via --init-file only on first run)
if [ -n "$INIT_SQL" ] && [ -s "$INIT_SQL" ]; then
  echo "Starting with init file"
  exec mysqld --user="$OSUSER" --datadir="$DATADIR" --bind-address="$BIND" --init-file="$INIT_SQL"
else
  echo "Starting without init file"
  exec mysqld --user="$OSUSER" --datadir="$DATADIR" --bind-address="$BIND"
fi
