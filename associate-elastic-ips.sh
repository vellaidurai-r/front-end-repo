#!/bin/bash

# Script to associate Elastic IPs with ECS Fargate tasks
# Usage: ./associate-elastic-ips.sh

REGION="ap-southeast-2"

# Allocation IDs
DEV_ALLOCATION_ID="eipalloc-0b1b1c71a537e4134"
STAGING_ALLOCATION_ID="eipalloc-082bbe3127a68a7ba"
PROD_ALLOCATION_ID="eipalloc-0c9ca80ac03158f9a"

# Function to get network interface ID for a task
get_network_interface_id() {
    local cluster=$1
    local service=$2
    
    local task_arn=$(aws ecs list-tasks \
        --cluster "$cluster" \
        --service-name "$service" \
        --region "$REGION" \
        --query 'taskArns[0]' \
        --output text)
    
    if [ "$task_arn" == "None" ] || [ -z "$task_arn" ]; then
        echo "No tasks found for $service"
        return 1
    fi
    
    local eni=$(aws ecs describe-tasks \
        --cluster "$cluster" \
        --tasks "$task_arn" \
        --region "$REGION" \
        --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' \
        --output text)
    
    echo "$eni"
}

# Function to associate Elastic IP
associate_eip() {
    local service=$1
    local allocation_id=$2
    local cluster=$3
    
    echo "Processing $service..."
    
    local eni=$(get_network_interface_id "$cluster" "frontend-service-$service")
    
    if [ -z "$eni" ]; then
        echo "❌ Failed to get ENI for $service"
        return 1
    fi
    
    echo "  Network Interface: $eni"
    
    # Try to disassociate first (in case it's already associated)
    aws ec2 disassociate-address \
        --allocation-id "$allocation_id" \
        --region "$REGION" 2>/dev/null || true
    
    sleep 2
    
    # Associate the Elastic IP
    local result=$(aws ec2 associate-address \
        --allocation-id "$allocation_id" \
        --network-interface-id "$eni" \
        --region "$REGION" \
        --query 'PublicIp' \
        --output text 2>&1)
    
    if [[ $result == *"error"* ]] || [[ $result == *"Error"* ]]; then
        echo "❌ Failed to associate: $result"
        return 1
    fi
    
    echo "✅ Associated: $result"
}

# Main execution
echo "🔗 Associating Elastic IPs to ECS Fargate Tasks"
echo "=============================================="
echo ""

associate_eip "dev" "$DEV_ALLOCATION_ID" "my-node-api-cluster-dev"
echo ""

associate_eip "staging" "$STAGING_ALLOCATION_ID" "my-node-api-cluster-staging"
echo ""

associate_eip "prod" "$PROD_ALLOCATION_ID" "my-node-api-cluster-prod"
echo ""

echo "=============================================="
echo "✅ Process completed!"
echo ""
echo "Static IPs:"
echo "  Dev: 54.206.155.49"
echo "  Staging: 54.66.148.95"
echo "  Production: 13.238.247.223"
