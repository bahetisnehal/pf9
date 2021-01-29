#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "No arguments supplied. Provide client name as an argument. e.g getvm.sh myusername"
	exit 1
fi

userName=$1
maxInstanceCount=10

echo "Check if any instances allotted to user "$userName

userInstance=$(aws ec2 describe-instances --filters Name=tag:owner,Values=$userName Name=instance-state-name,Values=running --query 'Reservations[*].Instances[*].[PrivateIpAddress]' --region us-west-2 --output text)

if [ ! -z '$userInstance' ]; 
then
  echo "There is already an instance allotted to you with IP address: " $userInstance
  exit 0
fi

echo "Check if maximum count of instances has reached" 

instanceCount=$(aws ec2 describe-instances --filters Name=tag:role,Values=pf9user --query 'Reservations[*].Instances[*].[InstanceId]' --region us-west-2 --output text | wc -l)
# aws cli can be used to deploy and terminate instances. I find terraform more flexible tool hence using it. 
if [[ $instanceCount -lt $maxInstanceCount ]] 
then
  echo "Deploy new VM"
  # Create a new Terraform configuration from the template
  mkdir -p ./terraform/pf9/$userName
  # Copy only the plan and variable files
  cp ./terraform/template/main.tf ./terraform/pf9/$userName
  #cp ./terraform/template/var.tfvars ./terraform/pf9/$userName
  
  cd ./terraform/pf9/$userName
  terraform init
  terraform apply -auto-approve -var "owner=$userName" 
  ipaddress=$(terraform output -raw instance_ip_addr)
  echo "New Vm has been allotted, IP Address:" $ipaddress
else 
  echo "Max count has reached!. Please try again later"
fi





