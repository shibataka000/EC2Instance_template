#!/bin/sh -v

TEMPLATES=/home/ubuntu/openvpn

# apt
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y openvpn easy-rsa libssl-dev openssl iptables-persistent

# Server sertificate
make-cadir /etc/openvpn/easy-rsa
cd /etc/openvpn/easy-rsa
cp $TEMPLATES/vars ./vars
. ./vars
./clean-all
./build-dh
./pkitool --initca
./pkitool --server server
cd ./keys
openvpn --genkey --secret ./ta.key
cp ca.crt server.crt server.key dh2048.pem ta.key /etc/openvpn
cp $TEMPLATES/server.conf /etc/openvpn/server.conf
service openvpn restart

# Routing
sed -ie "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
sysctl -p
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
/etc/init.d/iptables-persistent save

# Client sertificate
cd /etc/openvpn/easy-rsa
. ./vars
./pkitool client
cd keys
mkdir /etc/openvpn/client
cp ca.crt ta.key client.crt client.key /etc/openvpn/client
cd /etc/openvpn
chmod 755 ./client ./client/*
