---
name: CI/CD & Infra Bug Report
about: Сообщить об ошибке в пайплайне деплоя, конфигах Terraform/Ansible или падении сервисов
title: '[CI/CD-BUG] '
labels: 'bug, ci-cd, infrastructure'
assignees: ''
---

### Описание проблемы
Что пошло не так? (например: *упал GitHub Actions workflow*, *ошибка на этапе Terraform Apply*, *сервис не прошел healthcheck после автодеплоя*).

### Детали пайплайна
- **ID или название Workflow:** [например, `Deploy to Production` / `.github/workflows/deploy.yml`]
- **Номер сборки / Ссылка на лог:** [если применимо, номер рана в Actions]
- **Компонент:** [например, GitHub Actions / Terraform / Ansible / Docker Swarm / Nginx]

### Шаги или триггер, приведший к ошибке
1. Был сделан `git push` в ветку `...` / создан Pull Request / сработал плановый триггер.
2. Пайплайн остановился на шаге `...`.

### Логи ошибки / Вывод консоли
Скопируйте сюда кусок лога из GitHub Actions или вывода терминала (обязательно в блоке кода):
```text
# Вставьте логи ошибки от GitHub Actions, Terraform или Ansible сюда