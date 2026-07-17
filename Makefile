ENV_FILE := .env.uat
include database/database.mk
include $(ENV_FILE)
export
help:
	@echo "╭─────────────────────────────────────╮"
	@echo "│       Supporting infra commands     │"
	@echo "╰─────────────────────────────────────╯"
	@echo "db-backup (shortcut: db)"
	@echo "db-retention (shortcut: dr)"