#!/bin/bash

# Static IPs for Frontend Environments
# These Elastic IPs will remain constant across redeployments

echo "🌐 Frontend Static IP Configuration"
echo "===================================="
echo ""
echo "DEVELOPMENT Environment:"
echo "  Elastic IP: 54.206.155.49"
echo "  Allocation ID: eipalloc-0b1b1c71a537e4134"
echo "  Frontend URL: http://54.206.155.49:3000"
echo "  Backend URL: http://3.24.242.50:3000"
echo ""

echo "STAGING Environment:"
echo "  Elastic IP: 54.66.148.95"
echo "  Allocation ID: eipalloc-082bbe3127a68a7ba"
echo "  Frontend URL: http://54.66.148.95:3000"
echo "  Backend URL: http://3.25.70.32:3000"
echo ""

echo "PRODUCTION Environment:"
echo "  Elastic IP: 13.238.247.223"
echo "  Allocation ID: eipalloc-0c9ca80ac03158f9a"
echo "  Frontend URL: http://13.238.247.223:3000"
echo "  Backend URL: http://16.176.7.157:3000"
echo ""

echo "📋 Important Notes:"
echo "  ✅ Elastic IPs are FREE when associated with running instances"
echo "  ✅ IPs will remain STATIC across redeployments"
echo "  ✅ Cost: $0/month (while running on free tier)"
echo ""

echo "🔧 If IPs change after redeployment:"
echo "  1. Check current task network interface:"
echo "     aws ecs list-tasks --cluster <cluster> --service-name <service> --region ap-southeast-2"
echo "  2. Get network interface ID:"
echo "     aws ecs describe-tasks --cluster <cluster> --tasks <task-arn> --region ap-southeast-2"
echo "  3. Associate Elastic IP:"
echo "     aws ec2 associate-address --allocation-id <eip-alloc-id> --network-interface-id <eni-id> --region ap-southeast-2"
