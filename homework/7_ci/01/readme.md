# Задачи

*Сделайте autodetect конфигурации.*

![alt text](images/image1.png)

*Сохраните необходимые шаги, запустите первую сборку master.*

![alt text](images/image2.png)

*Поменяйте условия сборки: если сборка по ветке master, то должен происходит mvn clean deploy, иначе mvn clean test.*

![alt text](images/image3.png)

*Для deploy будет необходимо загрузить settings.xml в набор конфигураций maven у teamcity, предварительно записав туда креды для подключения к nexus.*

![alt text](images/image4.png)
![alt text](images/image5.png)

*Запустите сборку по master, убедитесь, что всё прошло успешно и артефакт появился в nexus.*

![alt text](images/image6.png)

*Убедитесь, что сборка самостоятельно запустилась, тесты прошли успешно.*

![alt text](images/image7.png)