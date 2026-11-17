## 1. Цель
Развернуть Kubernetes-кластер из пяти виртуальных машин в Yandex Cloud со следующими требованиями:

- 1 Master node (Control Plane);
- 4 Worker nodes;
- Container Runtime Interface (CRI) — `containerd`;
- `etcd` развёрнут на Master node;
- автоматизация создания инфраструктуры и установки Kubernetes.

Для выполнения работы использованы Terraform и Ansible. Установка Kubernetes выполняется с помощью `kubeadm`.

## 2. Используемые технологии


| Компонент | Технология |
|---|---|
| Облачная платформа | Yandex Cloud |
| Инфраструктура как код | Terraform |
| Автоматизация настройки | Ansible |
| Операционная система | Ubuntu 24.04 LTS |
| Контейнерный runtime | containerd |
| Оркестратор контейнеров | Kubernetes |
| Установка Kubernetes | kubeadm |
| Сетевой плагин CNI | Calico |
| Управление кластером | kubectl |
| Доступ к приватным ВМ | Bastion Host, SSH ProxyJump |


## 3. Архитектура инфраструктуры

В Yandex Cloud создана виртуальная сеть VPC с подсетью `10.0.1.0/24` в зоне `ru-central1-a`.

Для обеспечения безопасности Kubernetes-узлы не имеют публичных IP-адресов. Доступ к ним осуществляется через Bastion Host.

### 3.1. Состав инфраструктуры

| Виртуальная машина | Назначение | Внутренний IP |
|---|---|---|
| bastion | Bastion Host | 10.0.1.10 |
| testing-platform-web-1 | Master / Control Plane | 10.0.1.11 |
| testing-platform-web-2 | Worker 1 | 10.0.1.12 |
| testing-platform-web-3 | Worker 2 | 10.0.1.13 |
| testing-platform-web-4 | Worker 3 | 10.0.1.14 |
| testing-platform-web-5 | Worker 4 | 10.0.1.15 |

Каждая виртуальная машина Kubernetes имеет следующие характеристики:

- 2 vCPU;
- 2 GB RAM;
- 15 GB системный диск;
- Ubuntu 24.04 LTS.

Bastion Host имеет публичный IP-адрес и используется исключительно для организации административного доступа к приватным виртуальным машинам.

### 3.2. Схема инфраструктуры

```text
                 WSL Ubuntu (рабочая станция)
                           |
                       SSH / kubectl
                           |
                      Public IP
                           |
                    +-------------+
                    |   Bastion   |
                    | 10.0.1.10   |
                    +-------------+
                           |
                       SSH Jump
                           |
       +-------------------------------------------+
       |              Yandex Cloud VPC             |
       |               10.0.1.0/24                 |
       |                                           |
       |  +-------------------------------------+  |
       |  | Master / Control Plane              |  |
       |  | 10.0.1.11                           |  |
       |  |                                     |  |
       |  | kube-apiserver                      |  |
       |  | kube-scheduler                      |  |
       |  | kube-controller-manager             |  |
       |  | etcd                                |  |
       |  +-------------------------------------+  |
       |                                           |
       |  +----------------+  +----------------+   |
       |  | Worker 1       |  | Worker 2       |   |
       |  | 10.0.1.12      |  | 10.0.1.13      |   |
       |  +----------------+  +----------------+   |
       |                                           |
       |  +----------------+  +----------------+   |
       |  | Worker 3       |  | Worker 4       |   |
       |  | 10.0.1.14      |  | 10.0.1.15      |   |
       |  +----------------+  +----------------+   |
       |                                           |
       +-------------------------------------------+
```

### 3.3. Сетевая безопасность

Для ограничения доступа используются две Security Group:

**bastion-sg:**
- входящий SSH (TCP/22) разрешён только с административного IP;
- исходящий трафик разрешён.

**internal-vms-sg:**
- SSH (TCP/22) разрешён от Bastion Host (`10.0.1.10/32`);
- разрешён обмен трафиком между виртуальными машинами внутри Security Group;
- исходящий трафик разрешён.

Для доступа виртуальных машин в интернет используется NAT Gateway и таблица маршрутизации.

Kubernetes API Server не публикуется в интернет. Управление кластером осуществляется через SSH-туннель.

## 4. Создание инфраструктуры с помощью Terraform

Для создания инфраструктуры используется Terraform.

Основной файл конфигурации: `main.tf`.

Terraform выполняет следующие действия:

1. Создаёт виртуальную сеть VPC.
2. Создаёт подсеть `10.0.1.0/24`.
3. Создаёт NAT Gateway.
4. Создаёт таблицу маршрутизации.
5. Создаёт Security Group для Bastion.
6. Создаёт Security Group для внутренних виртуальных машин.
7. Создаёт Bastion Host с публичным IP.
8. Создаёт пять приватных виртуальных машин для Kubernetes.

Количество Kubernetes-узлов задаётся переменной `vm_count`:

```hcl
count = var.vm_count
```

Внутренние IP-адреса назначаются автоматически:

```hcl
ip_address = cidrhost(
  var.subnet_cidr,
  11 + count.index
)
```

Таким образом, создаются пять виртуальных машин с адресами от `10.0.1.11` до `10.0.1.15`.

### 4.1. Креды для подключения к Yandex Cloud

Используются из текущего конфига:

`yc config list`

, заданы в качестве переменных:

```
export YC_TOKEN=$(yc iam create-token)
export YC_FOLDER_ID=$(yc config get folder-id)
export YC_CLOUD_ID=$(yc config get cloud-id)
```


### 4.2. Применение Terraform

Инициализация проекта:

```bash
terraform init
```

Форматирование конфигурации:

```bash
terraform fmt
```

Проверка конфигурации:

```bash
terraform validate
```

Просмотр плана изменений:

```bash
terraform plan
```

Создание инфраструктуры:

```bash
terraform apply
```

## 5. Установка и настройка Kubernetes с помощью Ansible

Для автоматизации установки Kubernetes используется Ansible Playbook `main.yaml`.

Playbook состоит из четырёх этапов.

### 5.1. PLAY 1 — подготовка всех узлов

Первый этап выполняется на всех пяти Kubernetes-узлах.

Выполняются следующие действия:

1. Устанавливается hostname виртуальных машин.
2. Обновляется список пакетов Ubuntu.
3. Устанавливаются необходимые системные пакеты и `containerd`.
4. Загружаются модули ядра:
   - `overlay`;
   - `br_netfilter`.
5. Настраиваются параметры ядра через `sysctl`:
   - `net.bridge.bridge-nf-call-iptables = 1`;
   - `net.bridge.bridge-nf-call-ip6tables = 1`;
   - `net.ipv4.ip_forward = 1`.
6. Отключается swap.
7. Создаётся конфигурация `containerd`.
8. Включается и запускается служба `containerd`.
9. Подключается официальный репозиторий Kubernetes `pkgs.k8s.io`.
10. Устанавливаются пакеты:
    - `kubelet`;
    - `kubeadm`;
    - `kubectl`.
11. Версии установленных пакетов фиксируются через `apt hold`.

12. Устанавливается утилита `crictl` для взаимодействия с Container Runtime Interface (CRI) и диагностики контейнеров на Kubernetes-узлах. Установка `crictl` выполняется непосредственно на всех пяти узлах. Это позволяет диагностировать состояние контейнеров, Pod, образов и CRI runtime как на Master, так и на Worker-нодах.

13. Создаётся конфигурация `/etc/crictl.yaml`, в которой указывается Unix-сокет containerd.

Для взаимодействия kubeadm с containerd используется сокет:

```yaml
containerd_socket: unix:///run/containerd/containerd.sock
```

### 5.2. PLAY 2 — инициализация Master

Второй этап выполняется только на Master node.

Для инициализации Kubernetes используется `kubeadm init`:

```bash
kubeadm init \
  --apiserver-advertise-address=10.0.1.11 \
  --apiserver-cert-extra-sans=127.0.0.1,localhost \
  --pod-network-cidr=<POD_NETWORK_CIDR> \
  --service-cidr=<SERVICE_NETWORK_CIDR> \
  --cri-socket=unix:///run/containerd/containerd.sock
```

Значения CIDR задаются переменными Ansible.

В результате инициализации создаются компоненты Control Plane:

- kube-apiserver;
- kube-scheduler;
- kube-controller-manager;
- etcd.

**etcd** разворачивается локально на Master node в составе Control Plane (stacked etcd). Отдельные виртуальные машины для etcd не создаются.

После инициализации:

- создаётся каталог `/home/ubuntu/.kube`;
- копируется административный kubeconfig;
- устанавливается сетевой плагин Calico;
- проверяется доступность Kubernetes API Server на порту `6443`.

Для установки Calico используется официальный манифест проекта:

```bash
kubectl apply -f \
  https://raw.githubusercontent.com/projectcalico/calico/<CALICO_VERSION>/manifests/calico.yaml
```

Версия Calico определяется переменной `calico_version`.

### 5.3. PLAY 3 — подключение Worker-нод

Третий этап выполняется на четырёх Worker-нодах.

На Master генерируется команда подключения к кластеру:

```bash
kubeadm token create --print-join-command
```

Полученная команда передаётся на Worker-ноды.

Пример команды подключения:

```bash
kubeadm join <MASTER_API_ENDPOINT> \
  --token <TOKEN> \
  --discovery-token-ca-cert-hash sha256:<HASH> \
  --cri-socket=unix:///run/containerd/containerd.sock
```

Таким образом, все четыре Worker-ноды подключаются к Kubernetes Control Plane.

Токен подключения не выводится в логах Ansible благодаря параметру `no_log: true`.

### 5.4. PLAY 4 — проверка Kubernetes-кластера

На последнем этапе выполняется проверка состояния узлов и системных Pod.

Проверка узлов:

```bash
kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes -o wide
```

Проверка Pod:

```bash
kubectl --kubeconfig=/etc/kubernetes/admin.conf get pods -A
```

Результаты команд выводятся в Ansible.

### 5.5. Запуск Ansible Playbook

Запуск установки выполняется командой:

```bash
ansible-playbook -i inventory.ini main.yaml
```

## 6. Управление кластером с WSL Ubuntu

Для удалённого управления Kubernetes на рабочей станции установлена утилита `kubectl`. Для подключения к Master-ноде прописаны дополнительные настройки:

`~/.ssh/config`:
```
Host k8s-bastion
    HostName 84.252.130.197 # актуальный адрес bastion-сервера;
    User ubuntu
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes

Host k8s-master
    HostName 10.0.1.11
    User ubuntu
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
    ProxyJump k8s-bastion
```

Kubeconfig скопирован с Master node:

```bash
mkdir -p ~/.kube

scp k8s-master:/home/ubuntu/.kube/config ~/.kube/config

chmod 600 ~/.kube/config
```

Поскольку Master находится в приватной подсети, доступ к Kubernetes API организован через SSH-туннель.

В kubeconfig адрес Kubernetes API Server настроен на:

```yaml
server: https://127.0.0.1:16443
```
, замена адреса в kubeconfig:

```
kubectl config set-cluster "$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')" --server=https://127.0.0.1:16443
```

Запуск туннеля:

```bash
ssh -N -L 16443:127.0.0.1:6443 k8s-master
```

После запуска туннеля управление кластером выполняется обычными командами kubectl:

```bash
kubectl cluster-info
kubectl get nodes -o wide
kubectl get pods -A
kubectl get pods -n kube-system
```

SSH-туннель позволяет управлять кластером без публикации Kubernetes API в публичную сеть.

## 7. Результаты выполнения

### 7.1. Проверка состояния узлов

Для проверки состояния всех узлов используется команда:

```bash
kubectl get nodes -o wide
```

Ожидаемый результат:

- один узел с ролью `control-plane`;
- четыре узла с ролью Worker;
- все пять узлов находятся в состоянии `Ready`.

```
$ kubectl get nodes -o wide

NAME           STATUS   ROLES           AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION              CONTAINER-RUNTIME
k8s-master     Ready    control-plane   177m   v1.37.2   10.0.1.11     <none>        Ubuntu 24.04.5 LTS   6.8.0-149-generic (amd64)   containerd://2.2.1
k8s-worker-1   Ready    <none>          94m    v1.37.2   10.0.1.12     <none>        Ubuntu 24.04.5 LTS   6.8.0-149-generic (amd64)   containerd://2.2.1
k8s-worker-2   Ready    <none>          94m    v1.37.2   10.0.1.13     <none>        Ubuntu 24.04.5 LTS   6.8.0-149-generic (amd64)   containerd://2.2.1
k8s-worker-3   Ready    <none>          94m    v1.37.2   10.0.1.14     <none>        Ubuntu 24.04.5 LTS   6.8.0-149-generic (amd64)   containerd://2.2.1
k8s-worker-4   Ready    <none>          94m    v1.37.2   10.0.1.15     <none>        Ubuntu 24.04.5 LTS   6.8.0-149-generic (amd64)   containerd://2.2.1
```

### 7.2. Проверка системных Pod

Для проверки системных компонентов Kubernetes используется команда:

```bash
kubectl get pods -A -o wide
```

Проверяется состояние следующих компонентов:

- kube-apiserver;
- kube-controller-manager;
- kube-scheduler;
- etcd;
- kube-proxy;
- Calico.

Системные Pod должны находиться в штатном состоянии (`Running` или ожидаемом для конкретного компонента `Completed`).

```
$ kubectl get pods -A -o wide

NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE    IP                NODE           NOMINATED NODE   READINESS GATES
kube-system   calico-kube-controllers-846669895c-c8grr   1/1     Running   0          178m   192.168.235.194   k8s-master     <none>           <none>
kube-system   calico-node-fd676                          1/1     Running   0          95m    10.0.1.12         k8s-worker-1   <none>           <none>
kube-system   calico-node-fqjs4                          1/1     Running   0          95m    10.0.1.15         k8s-worker-4   <none>           <none>
kube-system   calico-node-nb678                          1/1     Running   0          178m   10.0.1.11         k8s-master     <none>           <none>
kube-system   calico-node-npwhd                          1/1     Running   0          95m    10.0.1.13         k8s-worker-2   <none>           <none>
kube-system   calico-node-xsx2z                          1/1     Running   0          95m    10.0.1.14         k8s-worker-3   <none>           <none>
kube-system   coredns-559f6c778d-8x8td                   1/1     Running   0          178m   192.168.235.193   k8s-master     <none>           <none>
kube-system   coredns-559f6c778d-j84md                   1/1     Running   0          178m   192.168.235.195   k8s-master     <none>           <none>
kube-system   etcd-k8s-master                            1/1     Running   0          179m   10.0.1.11         k8s-master     <none>           <none>
kube-system   kube-apiserver-k8s-master                  1/1     Running   0          179m   10.0.1.11         k8s-master     <none>           <none>
kube-system   kube-controller-manager-k8s-master         1/1     Running   0          179m   10.0.1.11         k8s-master     <none>           <none>
kube-system   kube-proxy-89w5h                           1/1     Running   0          95m    10.0.1.15         k8s-worker-4   <none>           <none>
kube-system   kube-proxy-ctzh7                           1/1     Running   0          178m   10.0.1.11         k8s-master     <none>           <none>
kube-system   kube-proxy-f9xw7                           1/1     Running   0          95m    10.0.1.12         k8s-worker-1   <none>           <none>
kube-system   kube-proxy-k6ftb                           1/1     Running   0          95m    10.0.1.14         k8s-worker-3   <none>           <none>
kube-system   kube-proxy-xjp8s                           1/1     Running   0          95m    10.0.1.13         k8s-worker-2   <none>           <none>
kube-system   kube-scheduler-k8s-master                  1/1     Running   0          179m   10.0.1.11         k8s-master     <none>           <none>
```

### 7.3. Проверка etcd на Master

Для проверки работы etcd на Master используется команда:

``````bash
sudo crictl ps -a --name etcd
``````

Также проверяется наличие манифеста статического Pod:

```bash
sudo ls -l /etc/kubernetes/manifests/etcd.yaml
```

Наличие запущенного контейнера etcd и манифеста подтверждает его размещение на Master node.

```
$ ssh k8s-master "sudo crictl ps -a --name etcd"

CONTAINER           IMAGE               CREATED             STATE               NAME                ATTEMPT             POD ID              POD                 NAMESPACE
f24ddacaa8c6f       270fbeb697171       3 hours ago         Running             etcd                0                   f1d314475c6cd       etcd-k8s-master     kube-system

$ ssh k8s-master "sudo ls -l /etc/kubernetes/manifests/etcd.yaml"
-rw------- 1 root root 2582 Nov 17 04:35 /etc/kubernetes/manifests/etcd.yaml
```

### 7.4. Проверка containerd

На каждом Kubernetes-узле проверяется состояние службы:

```bash
sudo systemctl is-active containerd
```

Проверка информации о runtime:

```bash
sudo crictl info
```

```
$ for node in 10.0.1.1{1..5}; do     echo "===== $node =====";     ssh -J ubuntu@jump_host ubuntu@$node "sudo systemctl is-active containerd
"; done
===== 10.0.1.11 =====
active
===== 10.0.1.12 =====
active
===== 10.0.1.13 =====
active
===== 10.0.1.14 =====
active
===== 10.0.1.15 =====
active

```

## 9. Вывод

В ходе выполнения домашнего задания была развёрнута инфраструктура в Yandex Cloud с использованием Terraform.

С помощью Ansible автоматизирована подготовка пяти виртуальных машин, установка и настройка containerd, kubeadm, kubelet и kubectl.

На первой виртуальной машине инициализирован Kubernetes Control Plane с локальным etcd. К кластеру подключены четыре Worker-ноды.

В качестве сетевого плагина установлен Calico. Для удалённого управления Kubernetes с рабочей станции используется kubectl через SSH-туннель к Master node.

Таким образом, реализован Kubernetes-кластер из пяти узлов: одного Master и четырёх Worker, использующий containerd в качестве CRI и etcd на Master node.
