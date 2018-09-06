#!/bin/sh
INSTANCE_ID=`terraform output instance_id`
SSH_KEY=$HOME/.ssh/aws_default
aws ec2 get-password-data --instance-id $INSTANCE_ID --priv-launch-key $SSH_KEY
