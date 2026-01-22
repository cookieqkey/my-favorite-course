locals {
web = "${var.vm_web_yandex_compute_instance.platform_id}-${var.vm_web_yandex_compute_instance.name}"
db = "${var.vm_db_yandex_compute_instance.platform_id}-${var.vm_db_yandex_compute_instance.name}"
}