#TODO: Подумать как это развернуть бэкап в кластере в котором БД
db-backup:
	@docker compose -f idocker-compose.yml --env-file $(ENV_FILE) run --rm db-backup
db-retention:
	@bash infrastructure/database/backup/db-backup-policy.sh
db: db-backup
dr: db-retention