#! /bin/bash

# Syntax: sh sshtun.sh SERVER:PORT InTunnel Network1 Network2 ... OutTunnel Network1 Network2

# $1 --> Destination Server
# $2 --> Your Home Network
SERVER="10.10.10.1"
PORT="9696"

NIC=`ip route show | grep default | cut -d ' ' -f 5`

GATEWAY=`ip route show | grep default | cut -d ' ' -f 3`
HOST_IP=`ip -4 addr show  dev wlp2s0 | grep inet | awk '{print $2}' | cut -d'/' -f1`
PREFIX=`ip -4 addr show  dev wlp2s0 | grep inet | awk '{print $2}' | cut -d'/' -f2`

IFS=. read -r i1 i2 i3 i4 <<< $HOST_IP
IFS=. read -r xx m1 m2 m3 m4 <<< $(for a in $(seq 1 32); do if [ $(((a - 1) % 8)) -eq 0 ]; then echo -n .; fi; if [ $a -le $PREFIX ]; then echo -n 1; else echo -n 0; fi; done)
HOST_NETWORK=`printf "%d.%d.%d.%d\n" "$((i1 & (2#$m1)))" "$((i2 & (2#$m2)))" "$((i3 & (2#$m3)))" "$((i4 & (2#$m4)))"`

InTunnel="192.168.10.0/27,192.168.10.98/27,192.168.10.128/27"
OutTunnel="172.16.0.0/16 172.30.0.0/16 192.168.1.0/24"

ip link del tun0
ssh -p ${PORT} root@${SERVER} 'ip link del tun1'

ssh -p ${PORT} -f -w 0:1 ${SERVER} true
ifconfig tun0 10.1.1.1 10.1.1.2 netmask 255.255.255.252
ssh -p ${PORT} root@${SERVER}  'ifconfig tun1 10.1.1.2 10.1.1.1 netmask 255.255.255.252'

ip rou add ${HOST_NETWORK}/${PREFIX} via ${GATEWAY} dev ${NIC}
ip rou add ${SERVER} via ${GATEWAY} dev ${NIC} proto static

ip rou add default dev tun0  proto static
if [ `echo $?` != 0 ]
	then
	ip rou ch default dev tun0  proto static
fi


iptables -t nat -F
iptables -t nat -I POSTROUTING -s $InTunnel -j MASQUERADE
ip route add $OutTunnel via 192.168.10.33 dev eth0


exit 0



## Tshoot:
# in termnal
## openvpn --mktun --dev tun0

## in sshd config:

#PermitTunnel yes
#AllowTcpForwarding yes


#ssh -p ${PORT} -f -w 10:11 root@${SERVER} true
#ifconfig tun10 192.168.50.1 pointopoint 192.168.50.2

#ip rou ch default dev tun10  proto static
#ssh -p ${PORT} root@${SERVER}  'ifconfig tun11 192.168.50.2 pointopoint 192.168.50.1'
