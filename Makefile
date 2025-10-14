NAME= inception

all: up

up:
	docker compose -f srcs/docker-compose.yml up -d --build

down:
	docker compose -f srcs/docker-compose.yml down

re: down up

clean:
	docker system prune -af
	docker volume prune -f
#puede que no funcione checkear php-fpm is running correctly
check-php-fpm:
	docker compose exec wordpress ps aux | grep php-fpm
check-php-fpm-curl:
	docker compose exec wordpress curl -i http://127.0.0.1:9000

.PHONY: all up re clean
