Faculty: [FICT](https://fict.itmo.ru) \
Course: [Network programming](https://github.com/itmo-ict-faculty/network-programming) \
Year: 2023/2024 \
Group: K34212 \
Author: Guseynov Guseyn Muradovich \
Lab: Lab4 \
Date of create: 06.12.2023 \
Date of finished: 07.12.2023

# Лабораторная работа №4 "Базовая 'коммутация' и туннелирование используя язык программирования P4"

## Цель работы
Изучить синтаксис языка программирования P4 и выполнить 2 обучающих задания от Open network foundation для ознакомления на практике с P4.

## Ход работы

### Basic Forwarding

1.  Vagrant и VirtualBox уже были установлены.

Склонировали репозиторий [p4lang/tutorials](https://github.com/p4lang/tutorials).

Перешли в папку vm-ubuntu-20.04: 

```cd vm-ubuntu-20.04``` 

Развернули тестовую среду:

```vagrant up```

Когда машина перезагрузилась, появился быть графический настольный компьютер с предустановленным необходимым программным обеспечением. На виртуальной машине есть две учетные записи пользователей: vagrant (пароль vagrant) и p4 (пароль p4). Учетная запись p4 — это та учетная запись, которую мы будем использовать.

![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab4/images/1.png)

2. Зашли под учетной записью p4 и  запустили Mininet:
   
```make run```

Появилась командная строка Mininet. Попробуем пропинговать хосты в топологии:

```mininet> h1 ping h2```

![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab4/images/2.png)


Хосты не пингуются, т. к. по умолчанию все пакеты сбрасываются.

Вышли из Mininet и затем остановили его:

```make stop```

3. Изменим файл ```basic.p4```, котрый содержит скелет программы P4, в котором ключевые фрагменты логики заменены ```TODO``` комментариями.

Заменим каждую ```TODO``` логику, реализующую недостающую часть.

Добавили парсеры для для Ethernet и IPv4.
```p4
parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        /* TODO: add parser logic */
        transition parse_ethernet;
        #transition accept;
    }
    
    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            TYPE_IPV4 : parse_ipv4;
            default : accept;
        }    
    }

    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition accept;
    }
}
```
Для пересылки  IPv4 пакетов установили выходной порт, обновили адрес назначения Ethernet адресом следующего перехода и исходный адрес Ethernet адресом коммутатора, поменяли значение TTL. 

Добавили таблицу, которая будет считывать адрес назначения IPv4 и вызывать ```drop``` либо ```ipv4_forward```.

```p4
control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    action drop() {
        mark_to_drop(standard_metadata);
    }

    action ipv4_forward(macAddr_t dstAddr, egressSpec_t port) {
        /* TODO: fill out code in action body */
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    table ipv4_lpm {
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            ipv4_forward;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = NoAction();
    }

    apply {
        /* TODO: fix ingress control logic
         *  - ipv4_lpm should be applied only when IPv4 header is valid
         */
        if (hdr.ipv4.isValid()) {
            ipv4_lpm.apply();
        }
    }
}
```
Добавили депарсер.
```p4
control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        /* TODO: add deparser logic */
        packet.emit(hdr.ethernet);
        packet.emit(hdr.ipv4);
    }
}
```
4. Снова запустили решение как в Шаге 2. На этот раз успешно выполнили проверку связи между любыми хостами в топологии.

![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab4/images/3.png)

5. Схема связи

![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab4/images/schema3.drawio.png)


### Basic Tunneling


1. Файл ```basic_tunnel.p4``` содержит реализацию базового IP-маршрутизатора. Также там содержатся комментарии, помеченные значком ```TODO```, которые указывают на функционал, который необходимо реализовать.

Изменим файл ```basic_tunnel.p4```.


Обновили парсер чтобы он извлекал либо ```myTunnel``` заголовок, либо ```ipv4``` заголовок на основе ```etherType ``` поля в заголовке Ethernet. 
```p4
state parse_ethernet {
    packet.extract(hdr.ethernet);
    transition select(hdr.ethernet.etherType) {
        TYPE_IPV4 : parse_ipv4;
        TYPE_MYTUNNEL : parse_myTunnel;
        default : accept;
    }
}
```
В парсер была добавлена функция извлечения заголовка ```myTunnel```.
```p4
state parse_myTunnel {
    packet.extract(hdr.myTunnel);
    transition select(hdr.myTunnel.proto_id) {
        TYPE_IPV4 : parse_ipv4;
        default : accept;    
    }
}
```
Определили функцию для устнаовки выходного порта.
```p4
#// TODO: declare a new action: myTunnel_forward(egressSpec_t port)
action myTunnel_forward(egressSpec_t port) {
    standard_metadata.egress_spec = port;
}
```
Определили таблицу для маршрутизации пакетов.
```p4
#// TODO: declare a new table: myTunnel_exact
#// TODO: also remember to add table entries!
table myTunnel_exact {
    key = {
        hdr.myTunnel.dst_id: exact;
    }
    actions = {
        myTunnel_forward;
        drop;
        NoAction;
    }
    size = 1024;
    default_action = NoAction();
}
```
Обновили функцию ```apply```.
```p4
apply {
    #// TODO: Update control flow
    if (hdr.ipv4.isValid() && !hdr.myTunnel.isValid()) {
        ipv4_lpm.apply();
    }
    if (hdr.myTunnel.isValid()) {
        myTunnel_exact.apply();
    }
}
```
Обновили депарсер.
```p4
control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        #// TODO: emit myTunnel header as well
        packet.emit(hdr.myTunnel);
        packet.emit(hdr.ipv4);
    }
}
```
2. Как в предыдущем задании, запустили командную строку Mininet.
Открыли два терминала для h1и h2 соответственно:

```mininet> xterm h1 h2```

4. Каждый хост включает в себя небольшой клиент и сервер обмена сообщениями на базе Python. В h2xterm запустили сервер:
   
```./receive.py```

Сначала  протестируем без туннелирования. В h1xterm отправили сообщение по адресу h2:

```./send.py 10.0.2.2 "P4 is cool"```

Пакет с переданным сообщением дошел до адресата.

![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab4/images/4.png)

4. Теперь тестируем с туннелированием. В h1xterm отправили сообщение по адресу h2:

```./send.py 10.0.2.2 "P4 is cool" --dst_id 2```

Пакет должен получен в h2.

![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab4/images/5.png)

Теперь отправили пакет на адрес h3, указав данные для заголовка туннелирования dst_id для h2:

```./send.py 10.0.3.3 "P4 is cool" --dst_id 2```

Пакет получен по адресу h2, даже если этот IP-адрес является адресом h3. Это связано с тем, что коммутатор больше не использует заголовок IP для маршрутизации, когда заголовок ```myTunnel``` находится в пакете.

![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab4/images/6.png)

5. Схема связи

![изображение](https://github.com/GuseynovGM/2023_2024-network-programming-k33212-Guseynov_G_M/blob/main/lab4/images/schema4.drawio.png)

## Вывод
В ходе работы был изучен синтаксис языка программирования P4 и выполнить 2 обучающих задания от Open network foundation для ознакомления на практике с P4.
