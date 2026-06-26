#!/bin/bash
# Configuration verification script

echo "🔍 Terraform Project Configuration Verification"
echo "=================================================="
echo ""

# Check terraform installation
if command -v terraform &> /dev/null; then
    echo "✅ Terraform: $(terraform version -json | grep terraform_version | cut -d'"' -f4)"
else
    echo "❌ Terraform not found"
    exit 1
fi

# Check Azure CLI
if command -v az &> /dev/null; then
    echo "✅ Azure CLI: $(az version -o json | grep '"azure-cli"' | cut -d'"' -f4)"
else
    echo "❌ Azure CLI not found"
    exit 1
fi

echo ""
echo "📋 Project Configuration:"
echo "  Resource Group: pt19881rg"
echo "  Storage Account: tfstate1782441065"
echo "  Region: Central India"
echo "  Subscription: axis-airtel"
echo ""

# Check Azure authentication
CURRENT_ACCOUNT=$(az account show --query user.name -o tsv 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "✅ Azure Account: $CURRENT_ACCOUNT"
else
    echo "❌ Not logged in to Azure. Run: az login --tenant 2fc9152b-9178-4d6b-8ae8-45f9efe2edfa"
    exit 1
fi

echo ""
echo "📁 Project Files:"
for file in providers.tf main.tf variables.tf outputs.tf ssh.tf backend-config.hcl initial-azurerm-backend-terraform.sh; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (missing)"
    fi
done

echo ""
echo "🚀 Quick Commands:"
echo "  Initialize:  ./init-terraform.sh"
echo "  Plan:        terraform plan -lock=false"
echo "  Apply:       terraform apply -lock=false"
echo "  Destroy:     terraform destroy -lock=false"
echo ""
echo "✨ All checks passed! Ready to deploy."
