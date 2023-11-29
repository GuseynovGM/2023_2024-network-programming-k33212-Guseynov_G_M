# nov/29/2023 20:49:59 by RouterOS 6.49.10
# software id = 
#
#
#
/interface bridge
add name=loopback
/interface ovpn-client
add certificate=name_1 cipher=aes256 connect-to=51.250.29.83 mac-address=\
    02:B2:4D:E7:21:03 name=ovpn-out1 port=443 user=GuseynovGM
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/interface ovpn-server server
set certificate=profile-2199784016870177322.ovpn_0 cipher=\
    blowfish128,aes128,aes256 enabled=yes port=443
/routing id
add disabled=no id=172.16.0.1 name=OSPF_ID select-dynamic-id=""
/routing ospf instance
add disabled=no name=ospf-1 originate-default=always router-id=OSPF_ID
/routing ospf area
add disabled=no instance=ospf-1 name=backbone
/ip address
add address=172.16.0.1 interface=loopback network=172.16.0.1
/ip dhcp-client
add disabled=no interface=ether1
/ip ssh
set always-allow-password-login=yes forwarding-enabled=both
/routing ospf interface
add authentication=md5 interface=ether1
/system ntp client
set enabled=yes server-dns-names=0.ru.pool.ntp.org
