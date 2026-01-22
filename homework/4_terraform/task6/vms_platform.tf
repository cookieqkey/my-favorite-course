### vms vars
## web
variable "vm_web_yandex_compute_image" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "Web OS family name"
}

variable "vm_web_yandex_compute_instance" {
  type        = object({ name = string, platform_id = string, cores = number, memory = number, core_fraction = number, preemptible = bool})
  default     = { name = "netology-develop-platform-web", platform_id = "standard-v1", cores = 2, memory = 1, core_fraction = 5, preemptible = true}
  description = "Web params"
}
## db
variable "vm_db_yandex_compute_image" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "DB OS family name"
}

variable "vm_db_yandex_compute_instance" {
  type        = object({ name = string, platform_id = string, cores = number, memory = number, core_fraction = number, preemptible = bool})
  default     = { name = "netology-develop-platform-db", platform_id = "standard-v1", cores = 2, memory = 2, core_fraction = 20, preemptible = true}
  description = "DB compute params"
}

## all VM
variable "vms_resources" {
  description = "Resources configuration for all VMs"
  type        = map(object({
    cores         = number
    memory        = number
    core_fraction = number
  }))
}

variable "metadata" {
  type = object({
    serial-port-enable = number
    ssh-keys           = string
  })
}