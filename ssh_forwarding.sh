#!/bin/bash

# Getting the Bastion 
aws ec2 describe-instances \
--filters "Name=owner-id,Values=738397695583" "Name=instance-state-name,Values=running" "Name=tag-value,Values=*_bastion" \
--query 'Reservations[*].Instances[*].{imageId:ImageId,publicIp:PublicIpAddress,privateIp:PrivateIpAddress}' \
--output json > /tmp/aws_bastion.json

# Getting the private instances
aws ec2 describe-instances \
--filters "Name=owner-id,Values=738397695583" "Name=instance-state-name,Values=running" "Name=tag-value,Values=*_private" \
--query 'Reservations[*].Instances[*].{imageId:ImageId,publicIp:PublicIpAddress,privateIp:PrivateIpAddress}' \
--output json > /tmp/aws_privates.json

# Set variables like json
bastion=$(cat /tmp/aws_bastion.json)
privates=$(cat /tmp/aws_privates.json)

# Init loop in order to create the config inside the config file
for row in $(echo "${privates}" | jq -r '.[][] | @base64'); do
    _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }

    ip=$(_jq '.privateIp')
    # echo $ip

cat >> /tmp/config <<EOF
Host server_${ip}
   HostName $ip
   User ubuntu
   ForwardAgent yes
   IdentityFile ~/.ssh/private_instance
EOF

    for row in $(echo "${bastion}" | jq -r '.[][] | @base64'); do
        _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
        }

        ip=$(_jq '.publicIp')
        # echo $ip

cat >> /tmp/config <<EOF
   ProxyCommand ssh ubuntu@${ip} -W %h:%p

EOF
    done

done

# Add the servers in the config file
cat /tmp/config >> ~/.ssh/config
