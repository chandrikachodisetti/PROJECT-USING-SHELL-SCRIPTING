#!/bin/bash

## no space after and before equal to(=)#####

ami_id="0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="sep92s.online"
hostedzone_id="Z02512341YMTQGODMGXYF"

for instance in $@
do 
    echo "creating instance:$instance"
done