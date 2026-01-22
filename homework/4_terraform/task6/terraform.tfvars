vms_resources = {
  web = {
    cores         = 2
    memory        = 1
    core_fraction = 5
  }
  db = {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
}

metadata = {
  serial-port-enable = 1
  ssh-keys           = "ubuntu:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBHtElwitN4uVFumEnhP/Zj3YBcNQh2GqzSLq3z2k/xs"
}