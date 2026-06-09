resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "develop" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}
resource "yandex_vpc_subnet" "develop_db" {
  name           = "${var.vpc_name}-db"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["10.0.2.0/24"]
}

data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_yandex_compute_image
}
resource "yandex_compute_instance" "platform" {
  name        = var.vm_web_yandex_compute_instance.name
  platform_id = var.vm_web_yandex_compute_instance.platform_id
  resources {
    cores         = var.vm_web_yandex_compute_instance.cores
    memory        = var.vm_web_yandex_compute_instance.memory
    core_fraction = var.vm_web_yandex_compute_instance.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_web_yandex_compute_instance.preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.vms_ssh_public_root_key}"
  }

}

resource "yandex_compute_instance" "platform_db" {
  name        = var.vm_db_yandex_compute_instance.name
  platform_id = var.vm_db_yandex_compute_instance.platform_id
  zone = "ru-central1-b"
  resources {
    cores         = var.vm_db_yandex_compute_instance.cores
    memory        = var.vm_db_yandex_compute_instance.memory
    core_fraction = var.vm_db_yandex_compute_instance.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_db_yandex_compute_instance.preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop_db.id
    nat       = true
  }

  metadata = {
    serial-port-enable = 1
    ssh-keys           = "ubuntu:${var.vms_ssh_public_root_key}"
  }

}