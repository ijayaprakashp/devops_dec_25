#!/bin/bash
# Auto-create EFS mount targets for all AZs of your Kubernetes nodes
# This version auto-picks the first subnet in each AZ

EFS_ID="fs-xxxxxxxxxxxx"   # Change to your EFS filesystem ID
REGION="ap-south-1"             # Change to your AWS region
SECURITY_GROUP="sg-xxxxxxxxxxxx"        # Security group attached to your nodes

# Get all node AZs
AZS=$(kubectl get nodes -o json | jq -r '.items[].metadata.labels["topology.kubernetes.io/zone"]' | sort | uniq)

for AZ in $AZS; do
    # Pick the first subnet in the AZ
    SUBNET_ID=$(aws ec2 describe-subnets \
        --filters "Name=availability-zone,Values=$AZ" \
        --query 'Subnets[0].SubnetId' --output text --region $REGION)
    
    if [ "$SUBNET_ID" == "None" ]; then
        echo "No subnet found in AZ $AZ, skipping..."
        continue
    fi

    echo "Creating mount target for AZ $AZ in subnet $SUBNET_ID..."
    aws efs create-mount-target \
        --file-system-id $EFS_ID \
        --subnet-id $SUBNET_ID \
        --security-groups $SECURITY_GROUP \
        --region $REGION
done

echo "All mount target creation requests submitted. Check with 'aws efs describe-mount-targets'."

echo "Checking EFS mount targets for $EFS_ID in $REGION..."
aws efs describe-mount-targets --file-system-id $EFS_ID --region $REGION