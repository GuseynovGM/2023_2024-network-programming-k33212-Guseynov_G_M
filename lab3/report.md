Faculty: [FICT](https://fict.itmo.ru) \
Course: [Network programming](https://github.com/itmo-ict-faculty/network-programming) \
Year: 2023/2024 \
Group: K34212 \
Author: Guseynov Guseyn Muradovich \
Lab: Lab3 \
Date of create: 02.11.2023 \
Date of finished: 03.11.2023

# Лабораторная работа №3 "Развертывание Netbox, сеть связи как источник правды в системе технического учета Netbox"

## Цель работы
Целью данной работы является с помощью Ansible и Netbox собрать всю возможную информацию об устройствах и сохранить их в отдельном файле.

## Ход работы
1. Подняли на YandexCloud новыу ВМ для установки NetBox. 
2. Установим на новую ВМ PostgreSQL, Redis, NetBox, Gunicorn и HTTP сервер nginx.
3. Установили базу данных PostgreSQL и проверили её состояние устновки и версию
```
sudo apt install -y postgresql
```
```
psql -V
```
4. Зашли в облочку PostgreSQL 
```
sudo -u postgres psql
```
5. Настроили PostgreSQL
```
CREATE DATABASE netbox;
CREATE USER netbox WITH PASSWORD 'admin';
GRANT ALL PRIVILEGES ON DATABASE netbox TO netbox;
```
6. Проверили работу PostgreSQL
```
psql --username netbox --password --host localhost netbox
```
```
\conninfo
```
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab3/images/1.%20PostgreSQL.png)

7. Установили хранилище данных Redis.  
```
sudo apt install -y redis-server
```
8. Проверили работоспособность Redis.
```
redis-cli ping
```
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab3/images/2.%20Redis.png)

9. Установим Python начиная с версии 3.8 и выше и пакеты к нему. 
```
sudo apt install -y python3 python3-pip python3-venv python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev
```
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab3/images/3.%20Python.png)

10. Создали новую папку в которую склонируем ветку master репозитория NetBox GitHub.
```
sudo mkdir -p /opt/netbox/
cd /opt/netbox/
```
11. Склонировали ветку master репозитория NetBox GitHub.
```
sudo git clone -b master --depth 1 https://github.com/netbox-community/netbox.git .
```
12. Создали учетную запись системного пользователя и выдали ему права собственности на указанные папки. 
```
sudo adduser --system --group netbox
sudo chown --recursive netbox /opt/netbox/netbox/media/
```
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab3/images/4.%20NetBox%20user.png)
13. Перешли в папку конфигурации NetBox и создали копию файла cnfiguratiom_example.py.
```
cd /opt/netbox/netbox/netbox/
sudo cp configuration_example.py configuration.py
```
14. Создали secret_key для дальнейшей настройки NetBox
```
python3 ../generate_secret_key.py
```
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab3/images/5.%20NetBox%20key.png)

15. Отредактировали файл configuration.py.
```
sudo vim configuration.py
```
```
ALLOWED_HOSTS = ['*']
```
```
DATABASE = {
    'NAME': 'netbox',               # Database name
    'USER': 'netbox',               # PostgreSQL username
    'PASSWORD': 'admin',            # PostgreSQL password
    'HOST': 'localhost',            # Database server
    'PORT': '',                     # Database port (leave blank for default)
    'CONN_MAX_AGE': 300,            # Max database connection age (seconds)
}
```
```
SECRET_KEY = 'TFSePTBmZplTjSxbZKxwOLzTDUSWpLA0^UQw628kqPcDQdv_kn'
```
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab3/images/6.%20NetBox%20set.png)

![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab3/images/7.%20NetBox%20set.png)

16. Запущен скрипт который нужен для:
*Создания виртуальной среды Python
*Устанавки всех необходимых пакетов Python
*Выполнения миграции схемы базы данных
*Сборки документации локально (для автономного использования)
*Агрегирования статических файлов ресурсов на диске
```
sudo /opt/netbox/upgrade.sh
```
17. Вошли в виртуальную среду python и создали суперпользователя
```
source /opt/netbox/venv/bin/activate
cd /opt/netbox/netbox
python3 manage.py createsuperuser
```
18. Настроим Gunicorn. Cкопирован конфигурационный файл, c необходимыми настройками и файлами.
```
sudo cp /opt/netbox/contrib/gunicorn.py /opt/netbox/gunicorn.py
sudo cp -v /opt/netbox/contrib/*.service /etc/systemd/system/
```
19. Перезапущен демон systemd
```
sudo systemctl daemon-reload
```
20. Запущены сервисы netbox и netbox-rq
```
sudo systemctl start netbox netbox-rq
sudo systemctl enable netbox netbox-rq
```
21. Проверен статус работы после настройки
```
systemctl status netbox
```
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab3/images/8.%20Gunicorn.png)

22. Настроен HTTP сервер. Установлен nginx и скопированны конфигурации файла 
```
sudo apt install -y nginx
sudo cp /opt/netbox/contrib/nginx.conf /etc/nginx/sites-available/netbox
```
23. Замена созданного по умолчанию nginx конфигурационный файл на файл который был созданный ранее
```
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/netbox /etc/nginx/sites-enabled/netbox
```
24. Перезапуск сервиса 
```
sudo systemctl restart nginx
```
25. Вход на веб версию NetBox

![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab3/images/9%20NetBox%20start.png)

27. Заполнение информации об устройствах в NetBox. Добавили в NetBox устройства - CHR1 и CHR2 и данные об их интерфесах и IP-адреса.

![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab3/images/10.%20NetBox%20add%20devices.png)


27. Сохранение данных из NetBox в отдельный файл netbox_inventory.yml с использованием модуля netbox.netbox.nb_inventory в Ansible.
```
---
plugin: netbox.netbox.nb_inventory
api_endpoint: https://51.250.29.83
token: токен
validate_certs: False
config_context: False
group_by:
  - device_roles
interfaces: 'True'
```
28. Сохраненная информация находиться в inventory-файле.
```
ansible-inventory -v --list -i netbox_inventory.yml > nb_inventory.yml
```
29. Настроенны два CHR сценария для смены имени и ip.
```
- name: Routers Configuration
  hosts: device_roles_router
  tasks:
    - name: Set Devices Name
      community.routeros.command:
        commands:
          - /system identity set name="{{interfaces[0].device.name}}"
    - name: Set additional IP
      community.routeros.command:
        commands:
        - /interface bridge add name="{{interfaces[1].display}}"
        - /ip address add address="{{interfaces[1].ip_addresses[0].address}}" interface="{{interfaces[1].display}}"
```
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab3/images/11.%20playbook.png)

30. Написание сценария для сбора серийного номера устройства и его вноса в NetBox 
```
- name: Get Serial Numbers To NetBox
hosts: device_roles_router
tasks:
  - name: Get Serial Number
    community.routeros.command:
      commands:
        - /system license print
    register: license_print
  - name: Get Name
    community.routeros.command:
      commands:
        - /system identity print
    register: identity_print
  - name: Add Serial Number to Netbox
    netbox_device:
      netbox_url: https://51.250.29.83
      netbox_token: токен
      data:
        name: "{{identity_print.stdout_lines[0][0].split(' ').1}}"
        serial: "{{license_print.stdout_lines[0][0].split(' ').1}}"
      state: present
      validate_certs: False
```
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab3/images/12.%20playbook.png)

![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab3/images/15.%20NetBox%20change%20SN.png)

![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab3/images/16.%20NetBox%20change%20SN.png)

31. Проверка ping на CHR1 и CHR2

![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab3/images/13.%20ping%20chr1.png)

![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab3/images/14.%20ping%20chr2.png)

32. Разработана итоговая схема.

![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab3/images/17.%20schema.png)
  
## Вывод
С помощью Ansible и Netbox собрали всю возможную информацию об устройствах и сохранили её в отдельном файле.
