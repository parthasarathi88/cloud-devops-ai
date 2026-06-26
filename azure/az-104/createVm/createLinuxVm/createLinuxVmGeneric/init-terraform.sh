#!/bin/bash
# Terraform initialization script for Azure backend with network filesystem compatibility
# Usage: ./init-terraform.sh [terraform init flags]

set -e

# Backend configuration
RESOURCE_GROUP="YOUR_RESOURCE_GROUP"
STORAGE_ACCOUNT="YOUR_STORAGE_ACCOUNT"
CONTAINER="tfstate"
KEY="terraform.tfstate"
ACCESS_KEY="YOUR_STORAGE_ACCOUNT_ACCESS_KEY"

echo "🔧 Initializing Terraform with Azure backend..."
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Storage Account: $STORAGE_ACCOUNT"
echo "   Container: $CONTAINER"
echo ""

# Initialize Terraform with backend config
terraform init \
  -backend-config="resource_group_name=$RESOURCE_GROUP" \
  -backend-config="storage_account_name=$STORAGE_ACCOUNT" \
  -backend-config="container_name=$CONTAINER" \
  -backend-config="key=$KEY" \
  -backend-config="access_key=$ACCESS_KEY" \
  -lock=false \
  "$@"

echo ""
echo "✅ Terraform initialized successfully!"
echo ""
echo "📝 Next steps:"
echo "   1. Review your infrastructure: terraform plan -lock=false"
echo "   2. Deploy resources: terraform apply -lock=false"
echo "   3. Destroy resources: terraform destroy -lock=false"
echo ""
echo "⚠️  Remember: Always use -lock=false on network filesystems!"
