#!/bin/bash

## no space after and before equal to(=)#####

ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="sep92s.online"
hosted_zone_id="Z02512341YMTQGODMGXYF"

##creating ec2 instance and get the  instance id ####

for instance in $@ ######(loops)

do 
    echo "creating instance: $instance"

    instance_id=$(aws ec2 run-instances \
  --image-id $ami_id \
  --instance-type $instance_type \
  --security-groups "roboshop-common" "roboshop-$instance"\
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
  --query 'Instances[0].InstanceId' \
  --output text
  )
    echo "$instance instance ID: $instance_id"    

    ##get the public and private ip address##


if [ $instance != frontend ]; then ####conditions
    IP=$(aws ec2 describe-instances \
  --instance-ids "$instance_id" \
  --query 'Reservations[].Instances[].PrivateIpAddress' \
  --output text
    )
    r53_record="$instance.${domain_name}"
else 
    IP=$(aws ec2 describe-instances \
  --instance-ids "$instance_id" \
  --query 'Reservations[].Instances[].PublicIpAddress' \
  --output text
    )
    r53_record="${domain_name}"
fi   
   echo "record: ${r53_record}"
     aws r53 change-resource-record-sets \
       --hosted-zone-id "$hosted_zone_id" \
     --change-batch '{
    "Changes": [
       {
          "Action": "UPSERT",
          "ResourceRecordSet": {
          "Name": "'$r53_record'",
          "Type": "A",
          "TTL": 1,
          "ResourceRecords": [{"Value": "'$IP'"}]
              } 
        }
    ]
}'
      echo "Updated r53 record for $instance"
done
   