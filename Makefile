u:
	docker compose up
us:
	docker compose up backend frontend db
b:
	docker compose build
no-cache:
	docker compose build --no-cache --force-rm
remake:
	@make destroy
	@make up
stop:
	docker compose stop
d:
	docker compose down --remove-orphans
restart:
	@make down
	@make up
destroy:
	docker compose down --rmi all --volumes --remove-orphans
destroy-volumes:
	docker compose down --volumes --remove-orphans
ps:
	docker compose ps
logs:
	docker compose logs
log-app:
	docker compose logs app
log-app-watch:
	docker compose logs --follow app
front:
	docker compose exec frontend bash
back:
	docker compose exec backend bash
db:
	docker compose exec db bash
at:
	docker attach backend
bundle:
	docker compose run backend bundle install -j 4
rubocop:
	docker compose exec backend bundle exec rubocop -A
cleanup:
	docker compose down -v
dsu:
	docker-sync-stack start
dss:
	docker-sync-stack stop
console:
	docker compose exec backend rails console
runner:
	docker compose exec backend rails runner