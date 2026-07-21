#!/bin/bash

set -e

echo "Запуск контейнеров"
docker compose up -d

echo "Ожидание запуска"
sleep 5

echo "Запуск плейбука"
ansible-playbook \
    -i inventory/prod.yml \
    site.yml \
    --ask-vault-pass

echo "Остановка контейнеров"
docker compose down

echo "Done"