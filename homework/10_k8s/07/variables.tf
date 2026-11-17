variable "zone" {
  description = "Зона доступности Yandex Cloud"
  type        = string
  default     = "ru-central1-a"
}

variable "network_name" {
  description = "Название облачной сети"
  type        = string
  default     = "testing"
}

variable "subnet_name" {
  description = "Название подсети"
  type        = string
  default     = "testing-ru-central1-a"
}

variable "subnet_cidr" {
  description = "CIDR подсети"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_key_path" {
  description = "Путь к публичному SSH-ключу"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "admin_cidr" {
  description = "Внешний IP администратора с маской /32"
  type        = string
}

variable "vm_count" {
  description = "Количество внутренних виртуальных машин"
  type        = number
  default     = 5
}

variable "preemptible" {
  description = "Использовать прерываемые ВМ"
  type        = bool
  default     = false
}
