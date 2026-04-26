#!/bin/bash

# Launch EC2 t2.micro Instance for Frontend
# Region: ap-southeast-2 (Sydney)
# Free Tier: YES (750 hours/month)

REGION="ap-southeast-2"
INSTANCE_TYPE="t2.micro"
IMAGE_ID="ami-0c802847a7dd848c0"  # Amazon Linux 2 in ap-southeast-2
SECURITY_GROUP="sg-0a7e12ada81af1163"
SUBNET="subnet-0e78938ff89580027"

echo "🚀 Launching EC2 t2.micro Instance"
echo "=================================="
echo ""
echo "Configuration:"
echo "  Region: $REGION"
echo "  Instance Type: $INSTANCE_TYPE"
echo "  Image: Amazon Linux 2"
echo "  Security Group: $SECURITY_GROUP"
echo ""

# Launch instance
echo "Launching instance..."
INSTANCE_JSON=$(aws ec2 run-instances \
  --image-id "$IMAGE_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --key-name your-key-pair \
  --security-group-ids "$SECURITY_GROUP" \
  --subnet-id "$SUBNET" \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=frontend-app},{Key=Environment,Value=all}]' \
  --monitoring Enabled=true \
  --region "$REGION" \
  --query 'Instances[0].[InstanceId, PrivateIpAddress]' \
  --output json)

INSTANCE_ID=$(echo $INSTANCE_JSON | jq -r '.[0]')
PRIVATE_IP=$(echo $INSTANCE_JSON | jq -r '.[1]')

echo "✅ Instance launched!"
echo ""
echo "📊 Instance Details:"
echo "  Instance ID: $INSTANCE_ID"
echo "  Private IP: $PRIVATE_IP"
echo "  Region: $REGION"
echo ""
echo "⏳ Waiting for instance to start..."
sleep 30

# Get public IP
echo "Getting public IP..."
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --region "$REGION" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo ""
echo "✅ Instance is running!"
echo ""
echo "🌐 Instance Public IP: $PUBLIC_IP"
echo ""
echo "🔑 SSH into instance:"
echo "  ssh -i your-key.pem ec2-user@$PUBLIC_IP"
echo ""
echo "📝 Next Steps:"
echo "  1. SSH into the instance"
echo "  2. Run the setup script: curl -O https://raw.githubusercontent.com/yourusername/your-repo/main/setup-ec2-frontend.sh"
echo "  3. chmod +x setup-ec2-frontend.sh"
echo "  4. ./setup-ec2-frontend.sh"
echo ""
echo "After setup, access your apps at:"
echo "  Dev:        http://$PUBLIC_IP:3000"
echo "  Staging:    http://$PUBLIC_IP:3001"
echo "  Production: http://$PUBLIC_IP:3002"
