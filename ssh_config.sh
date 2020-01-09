#!/bin/bash

namespace="$1"
file_config_personal="/tmp/config_personal"
file_config_temp="/tmp/config"
file_config_local="${HOME}/.ssh/config"

################################################
# Validate if exists file names and remove them
################################################
if [[ -e "/tmp/config_$namespace"  ]]; then
  echo "File ${namespace} already exists"
  
  rm "/tmp/config_$namespace"
  
  echo "File removed /tmp/config_$namespace"
#   exit 1
fi

if [[ -e ${file_config_personal}  ]]; then
  echo "File ${file_config_personal} already exists"
  
  rm "${file_config_personal}"
  
  echo "File removed ${file_config_personal}"
#   exit 1
fi

if [[ -e ${file_config_temp}  ]]; then
  echo "File ${file_config_temp} already exists"
  
  rm "${file_config_temp}"
  
  echo "File removed ${file_config_temp}"
#   exit 1
fi

# Just for testint
# cp /tmp/config_copy /tmp/config


########################
# Getting info from AWS
########################
# Bastion info
aws ec2 describe-instances \
--filters "Name=owner-id,Values=738397695583" "Name=instance-state-name,Values=running" "Name=tag-value,Values=*_bastion" \
--query 'Reservations[*].Instances[*].{imageId:ImageId,publicIp:PublicIpAddress,privateIp:PrivateIpAddress}' \
--output json > /tmp/aws_bastion.json

# Private instances info
aws ec2 describe-instances \
--filters "Name=owner-id,Values=738397695583" "Name=instance-state-name,Values=running" "Name=tag-value,Values=*_private" \
--query 'Reservations[*].Instances[*].{imageId:ImageId,publicIp:PublicIpAddress,privateIp:PrivateIpAddress}' \
--output json > /tmp/aws_privates.json


# Copy your local config file to temp config personal for re-create it
cat "${file_config_local}" > "${file_config_personal}"
# cat ~/.ssh/config > /tmp/config_personal


# Set variables like json
bastion=$(cat /tmp/aws_bastion.json)
privates=$(cat /tmp/aws_privates.json)


# Init loop in order to create the config namespace file
for row in $(echo "${bastion}" | jq -r '.[][] | @base64'); do
    _jq() {
    echo ${row} | base64 --decode | jq -r ${1}
    }

    public_ip=$(_jq '.publicIp')

    for row in $(echo "${privates}" | jq -r '.[][] | @base64'); do
        _jq() {
        echo ${row} | base64 --decode | jq -r ${1}
        }

        # Set variables
        private_ip=$(_jq '.privateIp')
        host=${private_ip#*.*.*.}
        
# Creating config
cat >> "/tmp/config_${namespace}" <<EOF
Host server_${public_ip}_${host}
   HostName $private_ip
   User ubuntu
   ForwardAgent yes
   IdentityFile ${HOME}/.ssh/private_instance
   ProxyCommand ssh ubuntu@${public_ip} -W %h:%p

EOF
    
    done # end for ${privates}

done # end for ${bastion}


##########################
# Re-Creating config file
##########################
cat ${file_config_personal} > ${file_config_temp}
cat "/tmp/config_$namespace" >> ${file_config_temp}
# code "${file_config_temp}"


##########################
# Copy result in your local config file
##########################
cat ${file_config_temp} > "${file_config_local}" 

# code "${file_config_local}" 