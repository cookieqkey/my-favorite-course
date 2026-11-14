# Задания

## Задание 1

*Развернуть приложение (nginx + multitool), решить проблему конфигурации через ConfigMap и подключить веб-страницу.*

Скриншот вывода:

```
$ curl http://localhost:8080
Handling connection for 8080
<!DOCTYPE html>
<html lang="ru">
<body>
  <h1>Hi there, handsome</h1>
</body>
</html>
```

## Задание 2

*Развернуть приложение с доступом по HTTPS, используя самоподписанный сертификат.*

Скриншот вывода:

```
$ curl -k --resolve myapp.example.com:31216:10.0.1.16 https://myapp.example.com:31216/
<!DOCTYPE html>
<html lang="ru">
<body>
  <h1>Hi there, handsome</h1>
</body>
</html>
```

## Задание 3

*Создать пользователя с ограниченными правами (только просмотр логов и описания подов).*

Команды генерации сертификатов:
```
openssl x509 -in developer.crt -text -noout;
openssl req -new -key developer.key -out developer.csr -subj "/CN=developer";
sudo openssl x509 -req -in developer.csr -CA /var/snap/microk8s/current/certs/ca.crt -CAkey /var/snap/microk8s/current/certs/ca.key -CAcreateserial -out developer.crt -days 365;
```

Скриншот проверки прав:
```
$ kubectl get pods --as=developer
NAME                       READY   STATUS    RESTARTS   AGE
web-app-5465b4f5c6-8sshg   2/2     Running   0          57m
```