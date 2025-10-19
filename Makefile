NAME = inception
COMPOSE = docker compose -f srcs/docker-compose.yml

# Default rule
all: up

# 1.1 make or make up → builds and starts containers
up:
	@mkdir -p /home/mehernan/data/mariadb #NEW #asegurar que las carpetas data existen
	@mkdir -p srcs/mysql_data  #NEW      # ensure MariaDB data folder exists
	@$(COMPOSE) up -d --build
	@echo "✅  Containers up and running! All done."

# Stops and removes containers and networks (but not volumes)
down:
	@$(COMPOSE) down
	@echo "🛑  Containers stopped and removed."

# 1.2 make clean → stops and removes containers and images
clean: down
	@$(COMPOSE) down -v
	@docker system prune -af
	@echo "🧹  Docker system cleaned (containers, images, networks)."

# 1.3 make fclean → also removes volumes
fclean: clean
	@rm -rf srcs/mysql_data   #NEW  # remove local MariaDB data folder
	@docker volume prune -f
	@docker network prune -f
	@echo "🔥  Full cleanup complete (volumes removed)."

# 1.4 make re → rebuilds everything from scratch
re: fclean up

.PHONY: all up down clean fclean re

