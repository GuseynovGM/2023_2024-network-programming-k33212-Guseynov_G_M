University: [ITMO University](https://itmo.ru/ru/) \
Faculty: [FICT](https://fict.itmo.ru) \
Course: [Network programming](https://github.com/itmo-ict-faculty/network-programming) \
Year: 2023/2024 \
Group: K34212 \
Author: Guseynov Guseyn Muradovich \
Lab: Lab1 \
Date of create: 29.11.2023 \
Date of finished: 29.11.2023

# Лабораторная работа №1 "Установка CHR и Ansible, настройка VPN"

## Цель работы
Целью данной работы является развертывание виртуальной машины на базе платформы Yandex Cloud с установленной системой контроля конфигураций Ansible и установка CHR в VirtualBox.

## Ход работы
1. Развернули виртуальную машину с Ubuntu на Yandex Cloud. \
Установили python3 и Ansible:
```
sudo apt-get update
sudo apt install python3-pip
sudo pip3 install ansible
```
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab1/images/1.%20ansible.png)

2. На VirtualBox установили CHR (RouterOS). \
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab1/images/2microtik.png)


3. Cоздали свой OpenVPN сервер. \
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab1/images/3.%20openvpn.png)
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab1/images/4.%20openvpn.png)

4. Задали настройки OpenVPN сервера: \
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab1/images/5.%20TCP.png)
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab1/images/6.%20TLS%20off.png)

Создали нового пользователя и разрешили атоматический вход:

![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab1/images/7.%20user%20add.png)


Создали новый профайл и скачали его:

![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab1/images/8.%20profiles.png)


Добавили скачанный ранее профайл и импортировали сертификат: 

![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab1/images/9.%20cert.png)
5. Создали OpenVPN интерфейс, чтобы поднять VPN туннель для связи с сервером:
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab1/images/10.%20new%20interface.png)

6. Проверили соединение: \
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab1/images/11.%20conected.png)

7. В результате лабораторной работы была получена схема, представленная ниже.\
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab1/images/sch.jpg)

## Вывод
В ходе работы научились развертывать виртуальные машины и системы контроля конфигураций Ansible, а также организовали собственный VPN сервер.
