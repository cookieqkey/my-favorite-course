resource "yandex_compute_disk" "data_disk" {
  count = 3

  name = "disk-${count.index + 1}"
  size = 1
  type = "network-hdd"
}

resource "yandex_compute_instance" "storage" {
  name = "storage"
  platform_id = "standard-v1"
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.data_disk
    content {
      disk_id = secondary_disk.value.id
    }
  }

  scheduling_policy {
    preemptible = true
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.develop.id
    nat                = true
    security_group_ids = [
      yandex_vpc_security_group.example.id
    ]
  }

  metadata = {
    ssh-keys = "ubuntu:${local.vms_ssh_public_root_key}"
  }
}
