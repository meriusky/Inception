FROM wordpress:latest
EXPOSE 9000

USER root
RUN apt-get update && apt-get install -y mariadb-client iputils-ping
USER www-data

WORKDIR /var/www/html/
