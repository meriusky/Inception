# Start from Debian
FROM debian:bullseye

# Install MariaDB
RUN apt-get update && apt-get install -y mariadb-server && rm -rf /var/lib/apt/lists/*

# Copy initialization scripts (we’ll create them next)
COPY ./tools/setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh

# Copy custom MariaDB configuration (optional, for security tuning)
COPY ./conf/my.cnf /etc/mysql/my.cnf

# Expose default port
EXPOSE 3306

# Start MariaDB via setup script (handles secure setup & user creation)
ENTRYPOINT ["bash", "/usr/local/bin/setup.sh"]

