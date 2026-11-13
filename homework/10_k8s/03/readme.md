# Задания

## Задание 1

*Создать Deployment приложения, состоящего из двух контейнеров, обменивающихся данными.*

`описание пода с контейнерами (kubectl describe pods data-exchange)`:

```
$ kubectl describe pod/data-exchange-d56cd9694-dhrnt
Name:             data-exchange-d56cd9694-dhrnt
Namespace:        default
Priority:         0
Service Account:  default
Node:             my-little-k8s/10.0.1.16
Start Time:       Fri, 13 Nov 2026 05:54:31 +0300
Labels:           app=data-exchange
                  pod-template-hash=d56cd9694
Annotations:      cni.projectcalico.org/containerID: e71c36ec10405501bb55e8bcde295a94a959602d4c8f81a9bccafbe560e4778c
                  cni.projectcalico.org/podIP: 10.1.221.234/32
                  cni.projectcalico.org/podIPs: 10.1.221.234/32
Status:           Running
IP:               10.1.221.234
IPs:
  IP:           10.1.221.234
Controlled By:  ReplicaSet/data-exchange-d56cd9694
Containers:
  busybox:
    Container ID:  containerd://6896ddb5e349571c99b31face79363d6554cdedfeed3a885c98b031ba5c18697
    Image:         busybox:latest
    Image ID:      docker.io/library/busybox@sha256:a46257e06c82ad85242d0d38077d0a52d9896389ca60a1a59d3463db586e5fa4
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sh
      -c
      while true; do
        date >> /data/shared.txt
        sleep 5
      done
      
    State:          Running
      Started:      Fri, 13 Nov 2026 05:54:32 +0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /data from shared-volume (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-5rtxd (ro)
  multitool:
    Container ID:  containerd://1f59b7f3423f08c7c15ce25ac022976026e73e8e5b41b2fa127cf74cccd5bfb8
    Image:         wbitt/network-multitool
    Image ID:      docker.io/wbitt/network-multitool@sha256:98d24ba5e94c74b153603dc4022aa15100ce33bccf7d0d59f8c2a3e088c90471
    Port:          <none>
    Host Port:     <none>
    Command:
      sleep
      infinity
    State:          Running
      Started:      Fri, 13 Nov 2026 05:54:33 +0300
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /data from shared-volume (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-5rtxd (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       True 
  ContainersReady             True 
  PodScheduled                True 
Volumes:
  shared-volume:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:     
    SizeLimit:  <unset>
  kube-api-access-5rtxd:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  21s   default-scheduler  Successfully assigned default/data-exchange-d56cd9694-dhrnt to my-little-k8s
  Normal  Pulling    20s   kubelet            Pulling image "busybox:latest"
  Normal  Pulled     20s   kubelet            Successfully pulled image "busybox:latest" in 773ms (773ms including waiting). Image size: 2236767 bytes.
  Normal  Created    20s   kubelet            Container created
  Normal  Started    20s   kubelet            Container started
  Normal  Pulling    20s   kubelet            Pulling image "wbitt/network-multitool"
  Normal  Pulled     19s   kubelet            Successfully pulled image "wbitt/network-multitool" in 789ms (789ms including waiting). Image size: 26477354 bytes.
  Normal  Created    19s   kubelet            Container created
  Normal  Started    19s   kubelet            Container started
```

`вывод команды чтения файла (tail -f <имя общего файла>)`:

```
$ kubectl exec -it deployment/data-exchange -c multitool -- tail -f /data/shared.txt
Fri Nov 13 02:54:32 UTC 2026
Fri Nov 13 02:54:37 UTC 2026
Fri Nov 13 02:54:42 UTC 2026
Fri Nov 13 02:54:47 UTC 2026
Fri Nov 13 02:54:52 UTC 2026
Fri Nov 13 02:54:57 UTC 2026
Fri Nov 13 02:55:02 UTC 2026
Fri Nov 13 02:55:07 UTC 2026
```

## Задание 2

*Создать Deployment приложения, использующего локальный PV, созданный вручную.*

`2. Создать PV и PVC для подключения папки на локальной ноде, которая будет использована в поде.`:

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: data-exchange-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: ""
  hostPath:
    path: /mnt/k8s-pv/data-exchange
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-exchange-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: ""
  volumeName: data-exchange-pv
```

`3. Продемонстрировать, что контейнер multitool может читать данные из файла в смонтированной директории, в который busybox записывает данные каждые 5 секунд.`:

```
$ kubectl exec -it deployment/data-exchange -c multitool -- tail -f /data/shared.txt
Fri Nov 13 03:06:53 UTC 2026
Fri Nov 13 03:06:58 UTC 2026
Fri Nov 13 03:07:03 UTC 2026
Fri Nov 13 03:07:06 UTC 2026
Fri Nov 13 03:07:08 UTC 2026
Fri Nov 13 03:07:11 UTC 2026
Fri Nov 13 03:07:13 UTC 2026
Fri Nov 13 03:07:16 UTC 2026
Fri Nov 13 03:07:18 UTC 2026
Fri Nov 13 03:07:21 UTC 2026
Fri Nov 13 03:07:23 UTC 2026
Fri Nov 13 03:07:26 UTC 2026
```

`4. Удалить Deployment и PVC. Продемонстрировать, что после этого произошло с PV. Пояснить, почему. (Используйте команду kubectl describe pv).`:

Перешел в состояние Released после удаления PVC, т.к. PV имеет политику:

***Retain — после удаления PV ресурсы из внешних провайдеров автоматически не удаляются***

```
$ kubectl describe pv data-exchange-pv
Name:            data-exchange-pv
Labels:          <none>
Annotations:     pv.kubernetes.io/bound-by-controller: yes
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:    
Status:          Released
Claim:           default/data-exchange-pvc
Reclaim Policy:  Retain
Access Modes:    RWO
VolumeMode:      Filesystem
Capacity:        1Gi
Node Affinity:   <none>
Message:         
Source:
    Type:          HostPath (bare host directory volume)
    Path:          /mnt/k8s-pv/data-exchange
    HostPathType:  
Events:            <none>
```

`5. Продемонстрировать, что файл сохранился на локальном диске ноды. Удалить PV. Продемонстрировать, что произошло с файлом после удаления PV. Пояснить, почему.`:

```
$ sudo ls -lR /mnt/k8s-pv/data-exchange
/mnt/k8s-pv/data-exchange:
total 4
-rw-r--r-- 1 root root 1305 Nov 13 03:09 shared.txt
```

После удаления файл остался, т.к. PersistentVolume (PV) - это объект Kubernetes, описывающий подключение к хранилищу. При использовании hostPath Kubernetes не удаляет каталог и файлы на физической ноде при удалении самого PV + PV имеет политику Retain

## Задание 3

*Создать Deployment приложения, использующего PVC, созданный на основе StorageClass.*

`2. Создать SC и PVC для подключения папки на локальной ноде, которая будет использована в поде.`:

```
$ kubectl get pod,svc,pv,pvc
NAME                                 READY   STATUS    RESTARTS   AGE
pod/data-exchange-7545986ddb-vnl9v   2/2     Running   0          19s

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.152.183.1   <none>        443/TCP   45m

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                       STORAGECLASS       VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/pvc-d5d4bc6d-fc9a-4595-893b-dbb500bde359   1Gi        RWO            Retain           Bound    default/data-exchange-pvc   data-exchange-sc   <unset>                          9s

NAME                                      STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS       VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/data-exchange-pvc   Bound    pvc-d5d4bc6d-fc9a-4595-893b-dbb500bde359   1Gi        RWO            data-exchange-sc   <unset>                 19s
```

`3. Продемонстрировать, что контейнер multitool может читать данные из файла в смонтированной директории, в который busybox записывает данные каждые 5 секунд.`:

```
$ kubectl exec -it deployment/data-exchange -c multitool -- tail -f /data/shared.txt
Fri Nov 13 03:26:31 UTC 2026
Fri Nov 13 03:26:36 UTC 2026
Fri Nov 13 03:26:41 UTC 2026
Fri Nov 13 03:26:46 UTC 2026
Fri Nov 13 03:26:51 UTC 2026
Fri Nov 13 03:26:56 UTC 2026
Fri Nov 13 03:27:01 UTC 2026
Fri Nov 13 03:27:06 UTC 2026
Fri Nov 13 03:27:11 UTC 2026
```
