# Start from Debian
FROM debian:bullseye

# Install MariaDB
RUN apt-get update && apt-get install -y mariadb-server && rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /bin/bash mysqluser
RUN mkdir -p /home/mysqluser/data && chown -R mysqluser:mysqluser /home/mysqluser/data 
VOLUME /home/mysqluser/data

# Copy initialization scripts 
COPY ./tools/setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh

# Copy custom MariaDB configuration
COPY ./conf/my.cnf /etc/mysql/my.cnf

# Expose default port
EXPOSE 3306

# Start MariaDB via setup script (handles secure setup & user creation)
ENTRYPOINT ["bash", "/usr/local/bin/setup.sh"]
#ENTRYPOINT ["bash", "-c", "while true; do sleep 60; done"]

