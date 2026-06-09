# Задача 1
*- Инициализируйте проект, выполните код. Исправьте намеренно допущенные синтаксические ошибки. Ищите внимательно, посимвольно. Ответьте, в чём заключается их суть.*

Возникает ошибка:
```
│ Error: Error while requesting API to create instance: client-request-id = 82b24948-8fec-4068-bd67-b0f0ed2c1f93 client-trace-id = 722ee33c-af3a-4ac4-b045-c5e88de2d4c3 rpc error: code = FailedPrecondition desc = Platform "standart-v4" not found
│ 
│   with yandex_compute_instance.platform,
│   on main.tf line 15, in resource "yandex_compute_instance" "platform":
│   15: resource "yandex_compute_instance" "platform" {
│ 
```
, т.к. standart-v4 - не существует, существует standard-v4a, но выбран будет standard-1 c cores = 2 ;

*- Скриншот ЛК Yandex Cloud с созданной ВМ, где видно внешний ip-адрес;*

![image](./images/image1.png)

*- Скриншот консоли, curl должен отобразить тот же внешний ip-адрес;*

![image](./images/image2.png)

*- Ответьте, как в процессе обучения могут пригодиться параметры preemptible = true и core_fraction=5 в параметрах ВМ.*

preemptible = true - прерываемая ВМ, позволит случайно не потратить все деньги, если забыть удалить самостоятельно;
core_fraction = 5 - ограничивает долю процессорного времени выделяемого на ядро до 5%, также позволяет сэкономить

# Задача 2
*- Проверьте terraform plan. Изменений быть не должно.*

Изменений нет

# Задача 3

![image](./images/image3.png)

# Задача 4

*- В качестве решения приложите вывод значений ip-адресов команды **terraform output***

```
vm_info = {
  "db" = {
    "external_ip" = "89.169.173.202"
    "fqdn" = "epdqnsjto51ocloc4fhf.auto.internal"
    "instance_name" = "netology-develop-platform-db"
  }
  "web" = {
    "external_ip" = "89.169.133.98"
    "fqdn" = "fhm9e653u0koteb458fa.auto.internal"
    "instance_name" = "netology-develop-platform-web"
  }
}
```

# Задача 5

- *В файле locals.tf опишите в одном local-блоке имя каждой ВМ, используйте интерполяцию ${..} с НЕСКОЛЬКИМИ переменными по примеру из лекции.*
- *Замените переменные внутри ресурса ВМ на созданные вами local-переменные.*
- *Примените изменения.*

```
Apply complete! Resources: 0 added, 2 changed, 0 destroyed.

Outputs:

vm_info = {
  "db" = {
    "external_ip" = "89.169.173.202"
    "fqdn" = "epdqnsjto51ocloc4fhf.auto.internal"
    "instance_name" = "standard-v1-netology-develop-platform-db"
  }
  "web" = {
    "external_ip" = "89.169.133.98"
    "fqdn" = "fhm9e653u0koteb458fa.auto.internal"
    "instance_name" = "standard-v1-netology-develop-platform-web"
  }
}
```

# Задача 6

*Проверьте terraform plan. Изменений быть не должно.*

```
No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no changes are needed.
```