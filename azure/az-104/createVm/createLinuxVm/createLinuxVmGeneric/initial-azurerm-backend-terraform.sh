#!/bin/bash

###############################################################################
# Terraform Azure Setup Initialization Script
# Purpose: Verify all prerequisites and setup for Terraform deployment
# Usage: ./initial-azurerm-backend-terraform.sh [--auto-fix]
# Options:
#   --auto-fix    Automatically fix issues when possible
###############################################################################

set -e

# Parse arguments
AUTO_FIX="false"
if [ "$1" = "--auto-fix" ]; then
    AUTO_FIX="true"
    echo "🔧 Auto-fix mode enabled"
    echo ""
elif [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Terraform Azure Setup Verification Script"
    echo ""
    echo "Usage: ./initial-azurerm-backend-terraform.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --auto-fix    Automatically create/fix missing Azure resources"
    echo "                - Attempts Azure login if not authenticated"
    echo "                - Creates resource group if missing"
    echo "                - Creates storage account for state if missing"
    echo "                - Creates tfstate container if missing"
    echo "                - Runs terraform init if needed"
    echo "  --help, -h    Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./initial-azurerm-backend-terraform.sh              # Check prerequisites only"
    echo "  ./initial-azurerm-backend-terraform.sh --auto-fix   # Check and auto-fix everything"
    echo ""
    exit 0
fi

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

###############################################################################
# Helper Functions
###############################################################################

print_header() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
    echo ""
}

check_item() {
    local name="$1"
    local condition="$2"
    local fix_command="$3"
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    
    if eval "$condition"; then
        echo -e "${GREEN}✓ OK${NC} - $name"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${RED}✗ FAIL${NC} - $name"
        
        if [ -n "$fix_command" ] && [ "$AUTO_FIX" = "true" ]; then
            echo -e "${YELLOW}   Attempting to fix...${NC}"
            if eval "$fix_command" > /dev/null 2>&1; then
                echo -e "${GREEN}   ✓ Fixed!${NC}"
                # Recheck
                if eval "$condition"; then
                    PASSED_CHECKS=$((PASSED_CHECKS + 1))
                    FAILED_CHECKS=$((FAILED_CHECKS + 1))
                    return 0
                fi
            else
                echo -e "${RED}   ✗ Fix failed${NC}"
            fi
        fi
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
}

check_file() {
    local filename="$1"
    if [ -f "$filename" ]; then
        echo -e "${GREEN}✓ OK${NC} - File: $filename"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${RED}✗ FAIL${NC} - File: $filename (missing)"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

check_dir() {
    local dirname="$1"
    if [ -d "$dirname" ]; then
        echo -e "${GREEN}✓ OK${NC} - Directory: $dirname"
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        echo -e "${RED}✗ FAIL${NC} - Directory: $dirname (missing)"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
}

print_summary() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
    echo "Summary: $PASSED_CHECKS/$TOTAL_CHECKS checks passed"
    echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
    echo ""
    
    if [ $FAILED_CHECKS -eq 0 ]; then
        echo -e "${GREEN}🎉 All checks passed! Your environment is ready.${NC}"
        return 0
    else
        echo -e "${RED}⚠️  $FAILED_CHECKS check(s) failed. Please review above.${NC}"
        return 1
    fi
}

###############################################################################
# Main Checks
###############################################################################

print_header "1. TOOLS & PREREQUISITES"

# Check Terraform
check_item "Terraform installed" "command -v terraform &> /dev/null"
if command -v terraform &> /dev/null; then
    TF_VERSION=$(terraform version -json 2>/dev/null | grep '"terraform_version"' | cut -d'"' -f4)
    echo "         Version: $TF_VERSION"
fi

# Check Azure CLI
check_item "Azure CLI installed" "command -v az &> /dev/null"
if command -v az &> /dev/null; then
    AZ_VERSION=$(az version -o json 2>/dev/null | grep '"azure-cli"' | cut -d'"' -f4)
    echo "         Version: $AZ_VERSION"
fi

# Check Git
check_item "Git installed" "command -v git &> /dev/null"

print_header "2. PROJECT FILES"

# Check Terraform files
check_file "providers.tf"
check_file "main.tf"
check_file "variables.tf"
check_file "outputs.tf"
check_file "ssh.tf"
check_file "backend-config.hcl"

print_header "3. TERRAFORM STATE & CONFIG"

# Check .terraform directory
check_dir ".terraform"

# Check lock file
check_file ".terraform.lock.hcl"

print_header "4. AZURE AUTHENTICATION"

# Tenant ID from backend config (replace with your actual tenant ID)
TENANT_ID="your-tenant-id-here"

# Check Azure login
if az account show &> /dev/null; then
    ACCOUNT=$(az account show --query user.name -o tsv 2>/dev/null)
    SUBSCRIPTION=$(az account show --query name -o tsv 2>/dev/null)
    TENANT=$(az account show --query tenantId -o tsv 2>/dev/null)
    
    echo -e "${GREEN}✓ OK${NC} - Azure authentication"
    echo "         Account: $ACCOUNT"
    echo "         Subscription: $SUBSCRIPTION"
    echo "         Tenant: $TENANT"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${RED}✗ FAIL${NC} - Azure authentication (not logged in)"
    
    if [ "$AUTO_FIX" = "true" ]; then
        echo -e "${YELLOW}   Attempting to login with tenant: $TENANT_ID${NC}"
        
        # Try to login non-interactively first, then interactively if needed
        if az login --tenant "$TENANT_ID" --allow-no-subscriptions > /dev/null 2>&1; then
            echo -e "${GREEN}   ✓ Login successful!${NC}"
            
            # Verify login worked
            if az account show &> /dev/null; then
                ACCOUNT=$(az account show --query user.name -o tsv 2>/dev/null)
                echo "         Account: $ACCOUNT"
                PASSED_CHECKS=$((PASSED_CHECKS + 1))
            else
                echo -e "${RED}   ✗ Login verification failed${NC}"
                FAILED_CHECKS=$((FAILED_CHECKS + 1))
            fi
        else
            echo -e "${YELLOW}   Interactive login required. Please authenticate...${NC}"
            if az login --tenant "$TENANT_ID"; then
                echo -e "${GREEN}   ✓ Login successful!${NC}"
                PASSED_CHECKS=$((PASSED_CHECKS + 1))
            else
                echo -e "${RED}   ✗ Login failed${NC}"
                FAILED_CHECKS=$((FAILED_CHECKS + 1))
            fi
        fi
    else
        echo -e "${YELLOW}   To fix, run:${NC}"
        echo "   az login --tenant $TENANT_ID"
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

print_header "5. PROVIDER CONFIGURATION"

# Check if credentials are configured
if grep -q "client_id.*=" providers.tf && \
   grep -q "client_secret.*=" providers.tf && \
   grep -q "tenant_id.*=" providers.tf && \
   grep -q "subscription_id.*=" providers.tf; then
    
    CLIENT_ID=$(grep "client_id" providers.tf | grep -o '[a-f0-9-]\{36\}' | head -1)
    TENANT_ID=$(grep "tenant_id" providers.tf | grep -o '[a-f0-9-]\{36\}' | head -1)
    SUBSCRIPTION_ID=$(grep "subscription_id" providers.tf | grep -o '[a-f0-9-]\{36\}' | head -1)
    
    echo -e "${GREEN}✓ OK${NC} - Azure provider credentials configured"
    echo "         Client ID: ${CLIENT_ID:0:8}...${CLIENT_ID: -8}"
    echo "         Tenant ID: ${TENANT_ID:0:8}...${TENANT_ID: -8}"
    echo "         Subscription ID: ${SUBSCRIPTION_ID:0:8}...${SUBSCRIPTION_ID: -8}"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${RED}✗ FAIL${NC} - Azure provider credentials not fully configured"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

print_header "6. SCRIPTS"

# Check helper scripts
check_file "init-terraform.sh"
check_file "verify.sh"
check_file "initial-azurerm-backend-terraform.sh"

# Check if scripts are executable
if [ -x "init-terraform.sh" ]; then
    echo -e "${GREEN}✓ OK${NC} - init-terraform.sh is executable"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${YELLOW}⚠ WARNING${NC} - init-terraform.sh is not executable"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

print_header "7. GIT & VERSION CONTROL"

# Check .gitignore
check_file ".gitignore"

# Check if git repo
if [ -d ".git" ]; then
    echo -e "${GREEN}✓ OK${NC} - Git repository initialized"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
else
    echo -e "${YELLOW}⚠ INFO${NC} - Not a git repository (optional)"
    # Don't count this as failure
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

print_header "8. REMOTE STATE BACKEND"

# Check backend configuration
if grep -q "storage_account_name.*=.*tfstate" backend-config.hcl; then
    STORAGE_ACCOUNT=$(grep "storage_account_name" backend-config.hcl | cut -d'"' -f2)
    CONTAINER=$(grep "container_name" backend-config.hcl | cut -d'"' -f2)
    RESOURCE_GROUP=$(grep "resource_group_name" backend-config.hcl | cut -d'"' -f2)
    
    echo -e "${GREEN}✓ OK${NC} - Azure Storage backend configured"
    echo "         Resource Group: $RESOURCE_GROUP"
    echo "         Storage Account: $STORAGE_ACCOUNT"
    echo "         Container: $CONTAINER"
    PASSED_CHECKS=$((PASSED_CHECKS + 1))
    
    # Auto-create missing Azure resources if needed
    if [ "$AUTO_FIX" = "true" ] && az account show &> /dev/null; then
        
        # Check and create resource group
        if ! az group exists --name "$RESOURCE_GROUP" | grep -q "true"; then
            echo -e "${YELLOW}   Creating resource group: $RESOURCE_GROUP${NC}"
            az group create --name "$RESOURCE_GROUP" --location "Central India" > /dev/null 2>&1 || true
        fi
        
        # Check and create storage account
        if ! az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
            echo -e "${YELLOW}   Creating storage account: $STORAGE_ACCOUNT${NC}"
            az storage account create \
                --name "$STORAGE_ACCOUNT" \
                --resource-group "$RESOURCE_GROUP" \
                --location "Central India" \
                --sku Standard_LRS > /dev/null 2>&1 || true
        fi
        
        # Check and create container
        if ! az storage container exists --name "$CONTAINER" --account-name "$STORAGE_ACCOUNT" --query exists 2>/dev/null | grep -q "true"; then
            echo -e "${YELLOW}   Creating storage container: $CONTAINER${NC}"
            az storage container create \
                --name "$CONTAINER" \
                --account-name "$STORAGE_ACCOUNT" > /dev/null 2>&1 || true
        fi
        
        # Initialize Terraform if .terraform doesn't exist
        if [ ! -d ".terraform" ]; then
            echo -e "${YELLOW}   Running terraform init${NC}"
            terraform init -backend-config=backend-config.hcl -lock=false > /dev/null 2>&1 || true
        fi
    fi
else
    echo -e "${RED}✗ FAIL${NC} - Azure Storage backend not configured"
    FAILED_CHECKS=$((FAILED_CHECKS + 1))
fi
TOTAL_CHECKS=$((TOTAL_CHECKS + 1))

###############################################################################
# Summary and Next Steps
###############################################################################

print_summary
RESULT=$?

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}NEXT STEPS:${NC}"
echo ""

if [ $FAILED_CHECKS -eq 0 ]; then
    echo "1. Review infrastructure plan:"
    echo "   ${YELLOW}terraform plan -lock=false${NC}"
    echo ""
    echo "2. Deploy infrastructure:"
    echo "   ${YELLOW}terraform apply -lock=false${NC}"
    echo ""
    echo "3. Get outputs:"
    echo "   ${YELLOW}terraform output${NC}"
    echo ""
else
    if [ "$AUTO_FIX" = "false" ]; then
        echo "Run setup with auto-fix to attempt repairs:"
        echo "   ${YELLOW}./initial-azurerm-backend-terraform.sh --auto-fix${NC}"
        echo ""
    fi
    
    echo "Common fixes:"
    echo "  - Login to Azure: ${YELLOW}az login --tenant <your-tenant-id>${NC}"
    echo "  - Reinstall Terraform: ${YELLOW}brew install terraform${NC}"
    echo "  - Update Azure CLI: ${YELLOW}az upgrade${NC}"
    echo ""
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

exit $RESULT
