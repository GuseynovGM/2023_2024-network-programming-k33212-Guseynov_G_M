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
![изображение](lab1/images/1. ansible.png)
2. На VirtualBox установили CHR (RouterOS).
![изображение](lab1/images/1. ansible.png)
3. Cоздали свой OpenVPN сервер.
```
apt install openvpn-as
```
*тут будет 2 картинки*


4. Задали настройки OpenVPN сервера: \
*тут будет 2 картинки*

Создали нового пользователя и разрешили атоматический вход:

*тут будет картинка*


Создали новый профайл и скачали его:


*тут будет картинка*

Добавили скачанный ранее профайл и импортировали сертификат: 

*тут будет картинка*
6. Создали OpenVPN интерфейс, чтобы поднять VPN туннель для связи с сервером:
*тут будет картинка*

7. Проверили соединение: \
*тут будет картинка*

8. В результате лабораторной работы была получена схема, представленная ниже.
*тут будет картинка*

## Вывод
В ходе работы научились развертывать виртуальные машины и системы контроля конфигураций Ansible, а также организовали собственный VPN сервер.
