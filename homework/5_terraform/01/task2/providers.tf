terraform {
  required_version = "~> 1.12.0"

  required_providers {

    docker = {
      source  = "kreuzwerker/docker"
    }

    random = {
      source  = "hashicorp/random"
    }
  }
}

provider "docker" {
  host = "ssh://${var.ssh_user}@${var.vm_ip}"
}
