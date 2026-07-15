#!/bin/bash

set -e

echo "Starting containers..."
docker compose up -d

echo "Waiting containers..."
sleep 5

echo "Running ansible..."
ansible-playbook \
    -i inventory/prod.yml \
    site.yml \
    --ask-vault-pass

echo "Stopping containers..."
docker compose down

echo "Done"