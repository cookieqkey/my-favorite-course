# Readme

1. [Описание playbook](#Описание)
2. [Скриншоты задач](#Задачи)

## Описание

Playbook устанавливает:

- ClickHouse
- Vector
- Lighthouse

### Inventory

Используется inventory/prod.yml.

### Переменные

`group_vars/clickhouse/vars.yml`:
- clickhouse_version — версия Clickhouse.

`group_vars/vector/vars.yml`:
- vector_version — версия Vector.

### Теги

- clickhouse

- vector

- lighthouse

### Проверка

```
ansible-lint playbook/site.yml
```

```
ansible-playbook -i inventory/prod.yml playbook/site.yml --check
```

```
ansible-playbook -i inventory/prod.yml playbook/site.yml --diff
```

## Задачи

### Задача 2

*При помощи ansible-galaxy скачайте себе эту роль.*

```
$ ansible-galaxy install -r requirements.yml -p roles
Starting galaxy role install process
- extracting clickhouse to /opt/git/my-favorite-course/homework/6_ansible/04/playbook/roles/clickhouse
- clickhouse (1.13) was installed successfully
```
### Задача 4

*На основе tasks из старого playbook заполните новую role. Разнесите переменные между vars и default.*

```
$ ansible-galaxy role init vector-role
- Role vector-role was created successfully
```

### Задача 7

*Повторите шаги 3–6 для LightHouse. Помните, что одна роль должна настраивать один продукт.*

```
lighthouse-role/
├── README.md
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── tasks
│   └── main.yml
├── templates
│   └── lighthouse.conf.j2
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml

9 directories, 9 files
```

### Задача 8

*Выложите все roles в репозитории. Проставьте теги, используя семантическую нумерацию. Добавьте roles в requirements.yml в playbook.*

