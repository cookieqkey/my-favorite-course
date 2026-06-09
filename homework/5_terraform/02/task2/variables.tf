###cloud vars


variable "cloud_id" {
  type        = string
  default     = "b1gkitcki4emj740vd6k"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  default     = "b1glqk58srs3388a8og0"
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network & subnet name"
}


###ssh vars

variable "vms_ssh_public_root_key" {
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBHtElwitN4uVFumEnhP/Zj3YBcNQh2GqzSLq3z2k/xs"
  description = "ssh-keygen -t ed25519"
}

###yandex compute vars

variable "vm_web_yandex_compute_image" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "OS family name"
}

variable "vm_web_yandex_compute_instance" {
  type        = object({ name = string, platform_id = string, cores = number, memory = number, core_fraction = number, preemptible = bool})
  default     = { name = "netology-develop-platform-web", platform_id = "standard-v1", cores = 2, memory = 1, core_fraction = 5, preemptible = true}
  description = "Compute params"
}