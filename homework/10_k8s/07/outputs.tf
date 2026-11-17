# Публичный IP Bastion
output "bastion_public_ip" {
  description = "Публичный IP-адрес Bastion"
  value       = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

# Внутренний IP Bastion
output "bastion_private_ip" {
  description = "Внутренний IP-адрес Bastion"
  value       = yandex_compute_instance.bastion.network_interface[0].ip_address
}

# Приватные IP внутренних ВМ
output "internal_vms_private_ips" {
  description = "Внутренние IP-адреса пяти ВМ"
  value = [
    for vm in yandex_compute_instance.example :
    vm.network_interface[0].ip_address
  ]
}

# Имена внутренних ВМ
output "internal_vms_names" {
  description = "Имена внутренних ВМ"
  value       = yandex_compute_instance.example[*].name
}