#! /bin/bash

ip link del tun0
ssh -p 9696 root@104.236.118.201 'ip link del tun1'

ssh -p 9696 -f -w 0:1 104.236.118.201 true
ifconfig tun0 10.1.1.1 10.1.1.2 netmask 255.255.255.252
ssh -p 9696 root@104.236.118.201  'ifconfig tun1 10.1.1.2 10.1.1.1 netmask 255.255.255.252'

ip rou add 192.168.10.0/24 via 192.168.10.33 dev eth0
ip rou add 104.236.118.201 via 192.168.10.33 dev eth0  proto static

ip rou add default dev tun0  proto static
if [ `echo $?` != 0 ] 
	then
	ip rou ch default dev tun0  proto static
fi


iptables -t nat -F
iptables -t nat -I POSTROUTING -s 192.168.10.128/27 -j MASQUERADE

# Access to No Filtered Internet for Managmented devices:
iptables -t nat -A POSTROUTING -s 192.168.10.0/27 -j MASQUERADE

iptables -t nat -A POSTROUTING -s 192.168.10.98/27 -j MASQUERADE

# Access to  ParsPooyesh Network:
ip route add 172.16.0.0/16 via 192.168.10.33 dev eth0
ip route add 172.30.0.0/16 via 192.168.10.33 dev eth0
ip route add 192.168.1.0/24 via 192.168.10.33 dev eth0

# Access to Rightel Network:
ip route add 10.200.6.0/24 via 192.168.10.33 dev eth0

exit 0



## Tshoot:
# in termnal
## openvpn --mktun --dev tun0

## in sshd config:

#PermitTunnel yes
#AllowTcpForwarding yes


#ssh -p 9696 -f -w 10:11 root@104.236.118.201 true
#ifconfig tun10 192.168.50.1 pointopoint 192.168.50.2

#ip rou ch default dev tun10  proto static
#ssh -p 9696 root@104.236.118.201  'ifconfig tun11 192.168.50.2 pointopoint 192.168.50.1'

