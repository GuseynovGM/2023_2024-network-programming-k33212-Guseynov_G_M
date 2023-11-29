University: [ITMO University](https://itmo.ru/ru/) \
Faculty: [FICT](https://fict.itmo.ru) \
Course: [Network programming](https://github.com/itmo-ict-faculty/network-programming) \
Year: 2023/2024 \
Group: K34212 \
Author: Guseynov Guseyn Muradovich \
Lab: Lab2 \
Date of create: 29.11.2023 \
Date of finished: 30.11.2023

# Лабораторная работа №2 "Развертывание дополнительного CHR, первый сценарий Ansible"

## Цель работы
Целью данной работы является с помощью Ansible настроить несколько сетевых устройств и собрать информацию о них и правильно собрать файл Inventory (hosts).

## Ход работы
1. Склонировали нашу первую CHR в Oracle VirtualBox. Организовали второй OVPN Client на CHR как и в первой лабораторной работе. 
2. Установили библиотеку Ansible для работы по SSH. 
```
pip install --user ansible-pylibssh
```
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab2/images/1.%20ansible.png)
3. Создали файл hosts, в котором прописали настройки первого и второго CHR. 
```
[chr]
chr1 ansible_host=172.27.224.25
chr2 ansible_host=172.27.224.24

[chr:vars]
ansible_connection=ansible.netcommon.network_cli
ansible_network_os=community.routeros.routeros
ansible_user=admin
ansible_ssh_pass=admin
```

4. Проверим подключение согласно данныи из файла hosts. 
```
ansible all -m ping
```
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab2/images/2.%20ping%20chr.png)

5. Создали файл microtik.yml для настройки chr1 и chr2. 
```
---
- name:  CHR setting
  hosts: chr
  tasks:
    - name: Create users
      routeros_command:
        commands: 
          - /user add name=user group=read password=admin

    - name: Create NTP client
      routeros_command:
        commands:
          - /system ntp client set enabled=yes server=0.ru.pool.ntp.org
        
    - name: OSPF with router ID
      routeros_command:
        commands: 
          - /interface bridge add name=loopback
          - /ip address add address=172.16.0.1 interface=loopback network=172.16.0.1
          - /routing id add disabled=no id=172.16.0.1 name=OSPF_ID select-dynamic-id=""
          - /routing ospf instance add name=ospf-1 originate-default=always router-id=OSPF_ID
          - /routing ospf area add instance=ospf-1 name=backbone
          - /routing ospf interface-template add area=backbone auth=md5 auth-key=admin interface=ether1

    - name: Get facts
      routeros_facts:
        gather_subset:
          - interfaces
      register: output_ospf

    - name: Print output
      debug:
        var: "output_ospf"
```
6. Запускаем файл microtik.yml и видим что файл выполняется.
```
ansible-playbook microtik.yml
```
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab2/images/3.%20playbook.png)
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab2/images/4.%20playbook.png)

## Результаты
Проверим что у нас получилось после запуска файла с playbook
1. Видим текущих пользователей CHR 
```
user print
```
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab2/images/5.%20user.png)

2. Просмотрим связность устройств
```
Routing ospf neighbor print
```
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab2/images/6.%20ospf.png)

3. Пронаблюдаем итоговую конфигурацию устройств
```
export compact
```
Конфигурации устройств находятся в следующих файлах: \
[CHR1](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab2/CHR1.rsc) \
[CHR2](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab2/CHR2.rsc)

4. Создадим схему исходя из нашей системы \
![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab2/images/7.%20schene.png)

## Вывод
С помощью Ansible настроили несколько сетевых устройств и собрали информацию о них и создали файл Inventory (hosts) и собрали конфигурации устройств.
