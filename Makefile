COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/$(USER)/data

all: up

up:
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	docker compose -f $(COMPOSE_FILE) up -d --build

down:
	docker compose -f $(COMPOSE_FILE) down

clean: down
	docker system prune -a -f

fclean: clean
	sudo rm -rf $(DATA_DIR)/*

re: fclean up

logs:
	docker compose -f $(COMPOSE_FILE) logs -f

.PHONY: all up down clean fclean re logs