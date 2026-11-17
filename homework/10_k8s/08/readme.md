# Задания

*Создать сетевую политику или несколько политик для обеспечения доступа. Продемонстрировать, что трафик разрешён и запрещён*

Разрешенный трафик:
```
$ kubectl exec -n app deployment/frontend -- curl -sS --connect-timeout 3 --max-time 5 http://backend/
WBITT Network MultiTool (with NGINX) - backend-78b95cdcb4-zz44t - 10.1.221.234 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)

$ kubectl exec -n app deployment/backend -- curl -sS --connect-timeout 3 --max-time 5 http://cache/
WBITT Network MultiTool (with NGINX) - cache-64c4fb5dbd-g5qf7 - 10.1.221.236 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
```

Нелегальный трафик:
```
$ kubectl exec -n app deployment/frontend -- curl -sS --connect-timeout 3 --max-time 5 http://cache/
curl: (28) Connection timed out after 3000 milliseconds
command terminated with exit code 28

$ kubectl exec -n app deployment/backend -- curl -sS --connect-timeout 3 --max-time 5 http://frontend/
curl: (28) Connection timed out after 3001 milliseconds
command terminated with exit code 28
```