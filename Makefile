u:
	docker-compose up
b:
	docker-compose build
no-cache:
	docker-compose build --no-cache --force-rm
remake:
	@make destroy
	@make up
stop:
	docker-compose stop
d:
	docker-compose down --remove-orphans
restart:
	@make down
	@make up
destroy:
	docker-compose down --rmi all --volumes --remove-orphans
destroy-volumes:
	docker-compose down --volumes --remove-orphans
ps:
	docker-compose ps
logs:
	docker-compose logs
log-app:
	docker-compose logs app
log-app-watch:
	docker-compose logs --follow app
front:
	docker-compose exec front bash
back:
	docker-compose exec back bash
db:
	docker-compose exec db bash
attach:
	docker attach