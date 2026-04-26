#!/bin/bash

# Backend Static IP Setup Script
# Automatically associates Elastic IPs to backend ECS tasks

set -e

REGION="ap-southeast-2"
ENV_NAMES=("dev" "staging" "prod")

echo "=== Backend Static IP Setup ==="
echo "Region: $REGION"
echo ""

# Step 1: Allocate or use existing Elastic IPs
echo "Step 1: Checking Elastic IP allocations..."

# Check available Elastic IPs
available_eips=$(aws ec2 describe-addresses --region "$REGION" --query 'Addresses[?AssociationId==null]' --output json)
echo "Available unassociated Elastic IPs:"
echo "$available_eips" | jq '.[] | {PublicIp: .PublicIp, AllocationId: .AllocationId}'

echo ""
echo "Step 2: Associating Elastic IPs to backend tasks..."

for env in "${ENV_NAMES[@]}"; do
  echo ""
  echo "--- Processing $env environment ---"
  
  cluster="my-node-api-cluster-$env"
  service="node-app-service-$env"
  
  # Get the task ARN
  task_arn=$(aws ecs list-tasks \
    --cluster "$cluster" \
    --service-name "$service" \
    --region "$REGION" \
    --query 'taskArns[0]' \
    --output text 2>/dev/null || echo "")
  
  if [ -z "$task_arn" ] || [ "$task_arn" == "None" ]; then
    echo "⚠️  No tasks found for $env"
    continue
  fi
  
  # Get the network interface
  task_details=$(aws ecs describe-tasks \
    --cluster "$cluster" \
    --tasks "$task_arn" \
    --region "$REGION" \
    --output json 2>/dev/null)
  
  eni=$(echo "$task_details" | jq -r '.tasks[0].attachments[0].details[1].value')
  current_ip=$(echo "$task_details" | jq -r '.tasks[0].attachments[0].details[3].value')
  
  echo "Task: $task_arn"
  echo "ENI: $eni"
  echo "Current Private IP: $current_ip"
  
  # Get current public IP
  public_ip=$(aws ec2 describe-network-interfaces \
    --network-interface-ids "$eni" \
    --region "$REGION" \
    --query 'NetworkInterfaces[0].PublicIpAddress' \
    --output text 2>/dev/null || echo "None")
  
  echo "Current Public IP: $public_ip"
  
  # Find an available Elastic IP (for staging, use the tagged one if available)
  if [ "$env" == "staging" ]; then
    eip_allocation=$(aws ec2 describe-addresses \
      --region "$REGION" \
      --filters "Name=tag:Name,Values=node-app-eip" \
      --query 'Addresses[0].AllocationId' \
      --output text 2>/dev/null || echo "")
    
    if [ -z "$eip_allocation" ] || [ "$eip_allocation" == "None" ]; then
      echo "❌ No tagged Elastic IP found for staging, allocating new one..."
      eip_allocation=$(aws ec2 allocate-address \
        --domain vpc \
        --region "$REGION" \
        --tag-specifications "ResourceType=elastic-ip,Tags=[{Key=Name,Value=node-app-eip-staging}]" \
        --query 'AllocationId' \
        --output text)
      echo "✅ Allocated new Elastic IP: $eip_allocation"
    fi
  else
    # For other environments, allocate new Elastic IPs
    echo "⚠️  Allocating new Elastic IP for $env..."
    eip_allocation=$(aws ec2 allocate-address \
      --domain vpc \
      --region "$REGION" \
      --tag-specifications "ResourceType=elastic-ip,Tags=[{Key=Name,Value=node-app-eip-$env}]" \
      --query 'AllocationId' \
      --output text)
    echo "✅ Allocated Elastic IP: $eip_allocation"
  fi
  
  # Get the public IP for this allocation
  eip_public=$(aws ec2 describe-addresses \
    --allocation-ids "$eip_allocation" \
    --region "$REGION" \
    --query 'Addresses[0].PublicIp' \
    --output text)
  
  echo "Elastic IP to associate: $eip_public ($eip_allocation)"
  
  # Check if already associated
  association=$(aws ec2 describe-addresses \
    --allocation-ids "$eip_allocation" \
    --region "$REGION" \
    --query 'Addresses[0].AssociationId' \
    --output text)
  
  if [ "$association" != "None" ] && [ ! -z "$association" ]; then
    echo "⚠️  Elastic IP already associated (ID: $association)"
    echo "   Disassociating first..."
    aws ec2 disassociate-address \
      --association-id "$association" \
      --region "$REGION"
    sleep 2
  fi
  
  # Associate the Elastic IP
  echo "Associating Elastic IP to ENI..."
  aws ec2 associate-address \
    --allocation-id "$eip_allocation" \
    --network-interface-id "$eni" \
    --region "$REGION"
  
  echo "✅ Successfully associated $eip_public to $env backend"
done

echo ""
echo "=== Summary ==="
echo "All backend environments have been configured with static IPs!"
echo ""
echo "Next: Update your frontend CI/CD configuration with these static IPs"
echo ""

# Display final configuration
echo "Update .github/workflows/frontend-cicd.yml with:"
echo ""
aws ec2 describe-addresses \
  --filters "Name=tag-key,Values=node-app-eip" \
  --region "$REGION" \
  --query 'Addresses[] | sort_by(@, &Tags[?Key==`Name`].Value|[0]) | [].{Environment: Tags[?Key==`Name`].Value|[0], PublicIP: PublicIp, AllocationId: AllocationId}' \
  --output table

echo ""
