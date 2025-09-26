#!/bin/bash


AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-075b1761b72424b2a" #Replace with your SG ID
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "frontend")
ZONE_ID="Z0141378IIM5EWRHRZJ0" #Replace with your hosted zone ID
DOMAIN_NAME="kishore7.space" #Replace with your domain name

for instance in ${INSTANCES[@]}
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-075b1761b72424b2a --tag-specifications "ResourceType=instance,Tags=[{Key=Name, Value=$instance}]" --query "Instances[0].InstanceId" --output text)
    if [ $instance !=  "frontend" ]
    then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
    fi
    echo "$instance IP address: $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
    {
       "Comment": "Creating or Updating a record for cognito endpoint"
       ,"Changes": [{
       "Action"              : "UPSERT",
       ,"ResourceRecordSet"  : {
           "Name"              : "'$instance'.'$DOMAIN_NAME'"
           ,"Type"             : "A"
           ,"TTL"              : "1"
           ,"ResourceRecords"  : [{
               "Value"         : "'$IP'"
          }]
        }
        }]
      }'
done