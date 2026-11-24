#!/bin/bash

## no space after and before equal to(=)#####

ami_id="0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="sep92s.online"
hostedzone_id="Z02512341YMTQGODMGXYF"

for instance in $@
do 
    echo "creating instance:$instance"

    instance_id:(aws ec2 run-instances \
  --image-id $ami_id \
  --instance-type $instance_type \
  --security-group-ids "roboshop-common" roboshop-$instance\
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]' \
  --query 'Instances[0].InstanceId' \
  --output text
  )
    echo "$instance ID:$instance_id"    
done
