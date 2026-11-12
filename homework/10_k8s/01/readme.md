# Задания

## Задание 1

*Создать Deployment приложения, состоящего из двух контейнеров — nginx и multitool. Решить возникшую ошибку*

образ wbitt/network-multitool сам запускает веб-сервер на портах 80 и 443, в одном pod с nginx возникает конфликт портов. Замена портов multitool через переменные окружения HTTP_PORT и HTTPS_PORT решает проблему:
```
        - name: multitool
          image: wbitt/network-multitool:latest
          env:
            - name: HTTP_PORT
              value: "8888"
            - name: HTTPS_PORT
              value: "8443"
```

*Продемонстрировать количество подов до и после масштабирования.*

До:
```
$ kubectl get pods
NAME                            READY   STATUS    RESTARTS   AGE
netology-web                    1/1     Running   1          3h8m
netology-web-5db8f4958d-9d5p8   2/2     Running   0          83s
```
После:
```
$ kubectl get pods
NAME                            READY   STATUS    RESTARTS   AGE
netology-web                    1/1     Running   1          3h9m
netology-web-5db8f4958d-9d5p8   2/2     Running   0          2m9s
netology-web-5db8f4958d-sjpc7   2/2     Running   0          4s
```

*Создать Service, который обеспечит доступ до реплик приложений из п.1.*

Service:
```
apiVersion: v1
kind: Service
metadata:
  name: netology-web-service
spec:
  selector:
    app: netology-web
  ports:
  - name: netology-web-port
    port: 80
    targetPort: web-port
```

*Создать отдельный Pod с приложением multitool и убедиться с помощью curl, что из пода есть доступ до приложений из п.1.*

Pod:
```

apiVersion: v1
kind: Pod
metadata:
  name: separated-multitool-pod
spec:

  initContainers:
    - name: check-other-pods
      image: wbitt/network-multitool:latest
      command:
        - /bin/sh
        - -c
        - |
          until curl -fsS http://netology-web-service; do
            echo "Waiting for service..."
            sleep 5
          done

  containers:
    - name: multitool
      image: wbitt/network-multitool:latest
      command: ['sleep', 'infinity']
```

, успешно выполненный `check-other-pods`:

```
Init Containers:
  check-other-pods:
    Container ID:  containerd://653f1839ac350f96906256a1a489b01a6a975e0f6a616145926ee7cd44e8113c
    Image:         wbitt/network-multitool:latest
    Image ID:      docker.io/wbitt/network-multitool@sha256:98d24ba5e94c74b153603dc4022aa15100ce33bccf7d0d59f8c2a3e088c90471
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
      until curl -fsS http://netology-web-service; do
        echo "Waiting for service..."
        sleep 5
      done
      
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Thu, 12 Nov 2026 16:04:52 +0300
      Finished:     Thu, 12 Nov 2026 16:04:53 +0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-mt7hs (ro)
```

## Задание 2

*Продемонстрировать состояние пода до и после запуска сервиса.*

До:
```
NAME                                READY   STATUS     RESTARTS   AGE
pod/netology-web                    1/1     Running    1          4h57m
pod/netology-web-6749564778-2ntd6   2/2     Running    0          94m
pod/netology-web-6749564778-d92rp   2/2     Running    0          94m
pod/nginx-init-6b9f4f4b97-7fnqj     0/1     Init:0/1   0          10s
pod/separated-multitool-pod         1/1     Running    0          57m

NAME                           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/kubernetes             ClusterIP   10.152.183.1    <none>        443/TCP   2d22h
service/netology-web-service   ClusterIP   10.152.183.27   <none>        80/TCP    4h57m
```

После:
```
NAME                                READY   STATUS    RESTARTS   AGE
pod/netology-web                    1/1     Running   1          4h58m
pod/netology-web-6749564778-2ntd6   2/2     Running   0          95m
pod/netology-web-6749564778-d92rp   2/2     Running   0          95m
pod/nginx-init-6b9f4f4b97-7fnqj     1/1     Running   0          69s
pod/separated-multitool-pod         1/1     Running   0          58m

NAME                           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/kubernetes             ClusterIP   10.152.183.1    <none>        443/TCP   2d22h
service/netology-web-service   ClusterIP   10.152.183.27   <none>        80/TCP    4h58m
service/nginx-service          ClusterIP   10.152.183.38   <none>        80/TCP    11s
```