# Задания

*Запуститe несколько копий приложения. Одну версию в namespace=app1, вторую версию в том же неймспейсе, третью версию в namespace=app2*

```
$ helm upgrade -i web-v1 ./web-app -n app1 --set appName=web-v1 --set welcomeMessage="Welcome to WEB V1" --set nginx.image.tag=1.26
Release "web-v1" does not exist. Installing it now.
NAME: web-v1
LAST DEPLOYED: Mon Nov 16 06:25:56 2026
NAMESPACE: app1
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None

$ helm upgrade -i web-v2 ./web-app -n app1 --set appName=web-v2 --set welcomeMessage="Welcome to WEB V2" --set nginx.image.tag=1.27
Release "web-v2" does not exist. Installing it now.
NAME: web-v2
LAST DEPLOYED: Mon Nov 16 06:26:28 2026
NAMESPACE: app1
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None

$ helm upgrade -i web-v3 ./web-app -n app2 --set appName=web-v3 --set welcomeMessage="Welcome to WEB V3" --set nginx.image.tag=1.28
Release "web-v3" does not exist. Installing it now.
NAME: web-v3
LAST DEPLOYED: Mon Nov 16 06:26:47 2026
NAMESPACE: app2
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None

$ helm list -A
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
traefik ingress         1               2026-11-13 01:48:15.721818767 +0000 UTC deployed        traefik-37.4.0  v3.6.2     
web-v1  app1            1               2026-11-16 06:25:56.054874414 +0300 MSK deployed        web-app-0.1.0   1.0.0      
web-v2  app1            1               2026-11-16 06:26:28.452356507 +0300 MSK deployed        web-app-0.1.0   1.0.0      
web-v3  app2            1               2026-11-16 06:26:47.437634706 +0300 MSK deployed        web-app-0.1.0   1.0.0

$ kubectl get deployments -A
NAMESPACE     NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
app1          web-v1-multitool          1/1     1            1           6m16s
app1          web-v1-nginx              1/1     1            1           6m16s
app1          web-v2-multitool          1/1     1            1           5m44s
app1          web-v2-nginx              1/1     1            1           5m44s
app2          web-v3-multitool          1/1     1            1           5m25s
app2          web-v3-nginx              1/1     1            1           5m25s
```