#!/bin/sh
MY_IPADDRESS=`curl -s https://ifconfig.co/`/32
echo "MY_IPADDRESS is $MY_IPADDRESS"
terraform apply -var my_ipaddress=$MY_IPADDRESS
