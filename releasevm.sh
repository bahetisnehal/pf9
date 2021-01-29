#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "No arguments supplied. Provide client name as an argument"
	exit 1
fi

userName=$1
maxInstanceCount=10

echo "Check if any instances allotted to user "$userName

userInstance=$(aws ec2 describe-instances --filters Name=tag:owner,Values=$userName --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --region us-west-2 --output text)

if [ -z '$userInstance' ]; 
then
  echo "There is no instance allotted to you !"
  exit 0
fi
echo "Terminate instance"
cd ./terraform/pf9/$userName
terraform destroy -auto-approve -var "owner=$userName" 

rm -r ./terraform/pf9/$userName






