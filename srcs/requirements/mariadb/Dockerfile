# Use the official MariaDB image as base
FROM mariadb:latest

# Set environment variables for the root password and database (these can be overridden in docker-compose.yml)
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=wordpress
ENV MYSQL_USER=wp_user
ENV MYSQL_PASSWORD=wp_pass

# Expose default MariaDB port
EXPOSE 3306

# Use the default command from the MariaDB image
CMD ["mysqld"]

