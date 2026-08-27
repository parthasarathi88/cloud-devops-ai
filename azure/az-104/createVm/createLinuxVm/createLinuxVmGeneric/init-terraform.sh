#!/bin/bash
# Terraform initialization script for local state with network filesystem compatibility
# Usage: ./init-terraform.sh [terraform init flags]

set -e

echo "🔧 Initializing Terraform with local state..."
echo ""

# Initialize Terraform using local backend (default)
terraform init \
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
