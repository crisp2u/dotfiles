#!/bin/bash

app=$1
env=$2

if [ $app == "" ]; then
	echo "unknown app"
	exit 1;
fi

env_long=""
if [ $env == "dev" ]; then
	env_long="development"
elif [ $env == "stage" ]; then
	env_long="staging"
elif [ $env == "prod" ]; then
	env_long="production"
else 
	echo "unknown environment"
	exit 1;
fi

echo "Setting profile to ${app}-${env}"
profile="${app}-${env}"

echo "Setting product to ${app}-${env_long}"
product="${app}-${env_long}"

echo "Fetching old security group ID..."
old_sg_id=$(aws ec2 describe-security-groups --filters "Name=tag:Name,Values=${product}-eks_worker_sg" --profile $profile --output json| jq -r '.SecurityGroups[] | .GroupId')
echo "> ${old_sg_id}"

echo "Fetching old security group ID..."
new_sg_id=$(aws ec2 describe-security-groups --filters "Name=tag:Name,Values=${product}-node" --profile $profile --output json| jq -r '.SecurityGroups[] | .GroupId')
echo "> ${new_sg_id}"

echo "Creating inbound rule for old security group (ID: ${old_sg_id})..."
aws ec2 authorize-security-group-ingress --group-id ${old_sg_id} --protocol "-1" --port -1 --source-group ${new_sg_id} --profile $profile --output json | jq .

echo "Creating inboud rule for new security group (ID: ${new_sg_id})..."
aws ec2 authorize-security-group-ingress --group-id ${new_sg_id} --protocol "-1" --port -1 --source-group ${old_sg_id} --profile $profile --output json | jq .