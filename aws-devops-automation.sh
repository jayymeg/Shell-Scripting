#! /usr/bin/bash

# Function to display usage information
usage() {
  echo "Usage: $0 <bucket-name> <app-path> <instance-id> <ami-id> <key-name> <security-group> <log-group-name> <alarm-name> <sns-topic-arn> <threshold>"
  exit 1
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 10 ]; then
  usage
fi

# Assign arguments to variables
BUCKET_NAME=$1
APP_PATH=$2
INSTANCE_ID=$3
AMI_ID=$4
KEY_NAME=$5
SECURITY_GROUP=$6
LOG_GROUP_NAME=$7
ALARM_NAME=$8
SNS_TOPIC_ARN=$9
THRESHOLD=${10}

# Function to set up the environment
setup_environment() {
  echo "Setting up environment..."
  sudo apt-get update
  sudo apt-get install -y awscli
  aws configure
}

# Function to create an S3 bucket
create_s3_bucket() {
  echo "Creating S3 bucket: $BUCKET_NAME"
  aws s3 mb s3://$BUCKET_NAME
}

# Function to launch an EC2 instance
launch_ec2_instance() {
  echo "Launching EC2 instance..."
  aws ec2 run-instances \
      --image-id $AMI_ID \
      --count 1 \
      --instance-type t2.micro \
      --key-name $KEY_NAME \
      --security-groups $SECURITY_GROUP
}

# Function to deploy the application
deploy_application() {
  echo "Deploying application to instance: $INSTANCE_ID"
  INSTANCE_PUBLIC_DNS=$(aws ec2 describe-instances \
      --instance-ids $INSTANCE_ID \
      --query "Reservations[0].Instances[0].PublicDnsName" \
      --output text)
  
  echo "Copying application files to EC2 instance..."
  scp -i $KEY_NAME.pem -r $APP_PATH ec2-user@$INSTANCE_PUBLIC_DNS:/home/ec2-user/

  echo "Deploying application on EC2 instance..."
  ssh -i $KEY_NAME.pem ec2-user@$INSTANCE_PUBLIC_DNS << EOF
    cd /home/ec2-user/$(basename $APP_PATH)
    ./deploy.sh
EOF
}

# Function to set up monitoring and logging
setup_monitoring_logging() {
  echo "Setting up CloudWatch log group: $LOG_GROUP_NAME"
  aws logs create-log-group --log-group-name $LOG_GROUP_NAME

  echo "Creating CloudWatch alarm: $ALARM_NAME"
  aws cloudwatch put-metric-alarm \
      --alarm-name $ALARM_NAME \
      --metric-name CPUUtilization \
      --namespace AWS/EC2 \
      --statistic Average \
      --period 300 \
      --threshold $THRESHOLD \
      --comparison-operator GreaterThanThreshold \
      --dimensions "Name=InstanceId,Value=$INSTANCE_ID" \
      --evaluation-periods 2 \
      --alarm-actions $SNS_TOPIC_ARN
}

# Execute functions
setup_environment
create_s3_bucket
launch_ec2_instance
deploy_application
setup_monitoring_logging

echo "AWS DevOps automation completed successfully!"
