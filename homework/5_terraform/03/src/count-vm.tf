# идентификатор ОС для vm
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "web" {
  
  depends_on = [
    yandex_compute_instance.db
  ]
  
  count = 2
  name = "web-${count.index + 1}"
  hostname = "web-${count.index + 1}"
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
    ssh-keys = "ubuntu:${file("~/.ssh/my-favorite-ed25519.key.pub")}"
  }
}