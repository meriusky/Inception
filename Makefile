NAME= inception

all: up

up:
	docke-compose -f rcs/docker-compose.yml up -d --build

down:
	docker-compose -f srcs/docker-compose.yml down

re: down up

clean:
	docker system prune -af
	docker volume prune -f

.PHONY: all up re clean
