#!/bin/sh
terraform apply

INSTANCE_ID=`terraform output instance_id`
PUBLIC_IP=`terraform output public_ip`
KEY_PAIR=~/.ssh/ec2_default.pem

echo
echo -n "Wait EC2 instance status become OK ... "
aws ec2 wait instance-status-ok --instance-ids $INSTANCE_ID
echo "Done"
echo

scp -i $KEY_PAIR ubuntu@$PUBLIC_IP:/etc/openvpn/client/* ./client

echo
echo "Setup VPN server was finished! You can connect to VPN Server $PUBLIC_IP "
echo
