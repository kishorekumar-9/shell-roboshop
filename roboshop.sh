#!/bin/bash


AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-075b1761b72424b2a" #Replace with your SG ID
INSTANCES=("mongodb" "redis" "rabbitmq" "catalogue" "user" "cart" "shipping")
ZONE_ID= "Z0141378IIM5EWRHRZJ0"
DOMAIN_NAME="kishore7.space"

for instance in ${INSTANCES[@]}
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t2.micro --security-group-ids sg-075b1761b72424b2a --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query "Instances[0].InstanceId" --output text)
    if [$instance !=  "frontend" ]
    then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
    fi
    echo "$instance IP address: $IP"
done