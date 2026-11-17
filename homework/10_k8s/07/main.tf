# Создаем облачную сеть
resource "yandex_vpc_network" "testing" {
  name = var.network_name
}

# Создаем подсеть
resource "yandex_vpc_subnet" "testing" {
  name           = var.subnet_name
  zone           = var.zone
  network_id     = yandex_vpc_network.testing.id
  v4_cidr_blocks = [var.subnet_cidr]
  route_table_id = yandex_vpc_route_table.testing.id
}

# NAT Gateway для доступа VMs в интернет
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "k8s-nat-gateway"

  shared_egress_gateway {}
}

# Таблица маршрутизации
resource "yandex_vpc_route_table" "testing" {
  name       = "testing-route-table"
  network_id = yandex_vpc_network.testing.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

# Получаем информацию об образе Ubuntu
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2404-lts"
}

# Security Group для Bastion
resource "yandex_vpc_security_group" "bastion" {
  name       = "bastion-sg"
  network_id = yandex_vpc_network.testing.id

  # Разрешаем SSH только с IP администратора
  ingress {
    protocol       = "TCP"
    description    = "SSH from administrator"
    v4_cidr_blocks = [var.admin_cidr]
    port           = 22
  }

  # Разрешаем исходящий трафик
  egress {
    protocol       = "ANY"
    description    = "Allow outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 65535

  }
}

# Security Group для внутренних ВМ (Kubernetes Master и Workers)
resource "yandex_vpc_security_group" "internal" {
  name        = "internal-vms-sg"
  description = "Security group for internal Kubernetes nodes"
  network_id  = yandex_vpc_network.testing.id

  # --------------------------------------------------------
  # Взаимодействие между всеми ВМ с этой Security Group
  # Разрешены все протоколы и порты внутри группы
  # --------------------------------------------------------

  ingress {
    protocol          = "ANY"
    description       = "Allow all traffic between internal VMs"
    predefined_target = "self_security_group"
  }

  # --------------------------------------------------------
  # SSH только от Bastion
  # --------------------------------------------------------

  ingress {
    protocol       = "TCP"
    description    = "SSH only from Bastion"
    v4_cidr_blocks = ["10.0.1.10/32"]
    port           = 22
  }

  # --------------------------------------------------------
  # Исходящий трафик
  # --------------------------------------------------------

  egress {
    protocol       = "ANY"
    description    = "Allow outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Создаем Bastion
resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  hostname    = "bastion"
  platform_id = "standard-v1"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      type     = "network-hdd"
      size     = 15
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${trimspace(file(pathexpand(var.public_key_path)))}"
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.testing.id
    ip_address = "10.0.1.10"
    nat        = true
    security_group_ids = [
      yandex_vpc_security_group.bastion.id
    ]
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  allow_stopping_for_update = true
}

# Создаем 5 внутренних виртуальных машин
resource "yandex_compute_instance" "example" {

  count = var.vm_count

  depends_on = [
    yandex_compute_instance.bastion
  ]

  name        = "testing-platform-web-${count.index + 1}"
  hostname    = "testing-platform-web-${count.index + 1}"
  platform_id = "standard-v1"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      type     = "network-hdd"
      size     = 15
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${trimspace(file(pathexpand(var.public_key_path)))}"
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.testing.id

    ip_address = cidrhost(
      var.subnet_cidr,
      11 + count.index
    )

    nat = false

    security_group_ids = [
      yandex_vpc_security_group.internal.id
    ]
  }

  allow_stopping_for_update = true

}


# --------------------------------------------------------
# Target Group для Kubernetes Control Plane
# Первые три ВМ являются Master-нодами
# --------------------------------------------------------

resource "yandex_lb_target_group" "k8s_masters" {
  name      = "k8s-masters-tg"
  region_id = "ru-central1"

  target {
    subnet_id = yandex_vpc_subnet.testing.id
    address   = yandex_compute_instance.example[0].network_interface[0].ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.testing.id
    address   = yandex_compute_instance.example[1].network_interface[0].ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.testing.id
    address   = yandex_compute_instance.example[2].network_interface[0].ip_address
  }
}
