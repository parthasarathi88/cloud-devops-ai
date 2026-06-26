# Azure Linux VM Terraform Project

## Overview
This Terraform configuration creates an Azure Linux VM with networking, security groups, and SSH key management.

## Remote State Backend
- **Storage Account:** `tfstate1782441065`
- **Container:** `tfstate`
- **Location:** Central India
- **Region:** centralindia

## Quick Start

### Prerequisites

### Required
- Terraform >= 0.12
- Azure CLI (`az` command)
- Git (for version control)

### Setup

**1. Clone the repository:**
```bash
git clone https://github.com/your-username/azure-terraform-linux-vm.git
cd azure-terraform-linux-vm/createLinuxVmGeneric
```

**2. Configure Azure Credentials**

Copy the example environment file:
```bash
cp .env.example .env
```

Edit `.env` and add your Azure credentials:
```bash
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_TENANT_ID="2fc9152b-9178-4d6b-8ae8-45f9efe2edfa"
export ARM_SUBSCRIPTION_ID="9377b510-ee3e-413b-bed0-ead0c0b7d639"
```

Load environment variables:
```bash
source .env
```

Or set them individually:
```bash
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_TENANT_ID="2fc9152b-9178-4d6b-8ae8-45f9efe2edfa"
export ARM_SUBSCRIPTION_ID="9377b510-ee3e-413b-bed0-ead0c0b7d639"
```

⚠️ **IMPORTANT:** `.env` is in `.gitignore` - never commit credentials to git!

**3. Create Azure Service Principal (if needed)**

If you don't have a service principal, create one:
```bash
az ad sp create-for-rbac --role Contributor --scopes /subscriptions/YOUR_SUBSCRIPTION_ID
```

This will output your credentials to use in `.env`.

### Step 1: Verify Setup
Run the setup verification script to check all prerequisites:

```bash
./initial-azurerm-backend-terraform.sh
```

**Or with auto-fix to create missing resources:**

```bash
./initial-azurerm-backend-terraform.sh --auto-fix
```

### Setup Script Options

```bash
./initial-azurerm-backend-terraform.sh                    # Check only (no changes)
./initial-azurerm-backend-terraform.sh --auto-fix         # Check and auto-create missing resources
./initial-azurerm-backend-terraform.sh --help             # Show help message
```

### What `initial-azurerm-backend-terraform.sh` Verifies

The script checks 8 categories (19-20 items):

1. **Tools & Prerequisites** - Terraform, Azure CLI, Git
2. **Project Files** - All required Terraform configuration files
3. **Terraform State & Config** - `.terraform` directory and lock file
4. **Azure Authentication** - Logged into Azure account
5. **Provider Configuration** - Azure credentials configured
6. **Scripts** - Helper scripts present and executable
7. **Git & Version Control** - `.gitignore` and repository setup
8. **Remote State Backend** - Azure Storage backend configured

### Auto-Fix Mode

When run with `--auto-fix`, the script will automatically:

✅ Authenticate with Azure (runs `az login --tenant` if needed)
✅ Create Azure resource group if missing
✅ Create storage account for Terraform state if missing
✅ Create tfstate container if missing
✅ Run `terraform init` if needed

This makes initial setup completely automated! Just run:

```bash
./initial-azurerm-backend-terraform.sh --auto-fix
```

And it handles everything for you - including Azure login.

### Step 2: Initialize Terraform
```bash
# Option 1: Using backend-config.hcl
terraform init -backend-config=backend-config.hcl -lock=false

# Option 2: Using the provided script
./init-terraform.sh

# Option 3: Manual init with flags (for network filesystems)
terraform init \
  -backend-config="resource_group_name=YOUR_RESOURCE_GROUP" \
  -backend-config="storage_account_name=YOUR_STORAGE_ACCOUNT" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=terraform.tfstate" \
  -backend-config="access_key=YOUR_STORAGE_ACCOUNT_ACCESS_KEY" \
  -lock=false
```

### Step 3: Plan & Apply
```bash
# Plan infrastructure changes (network filesystem compatibility)
terraform plan -lock=false

# Apply infrastructure changes (network filesystem compatibility)
terraform apply -lock=false
```

### Important Notes

⚠️ **Network Filesystem Locking Issue:**
- This workspace is on a network filesystem (SMB mount) which doesn't support file locking
- Always use `-lock=false` flag with `terraform plan`, `terraform apply`, and other commands
- Example: `terraform plan -lock=false`

🔐 **Credentials:**
Update `providers.tf` with your new Azure credentials:
```hcl
client_id       = "YOUR_CLIENT_ID"
client_secret   = "YOUR_CLIENT_SECRET"
tenant_id       = "YOUR_TENANT_ID"
subscription_id = "YOUR_SUBSCRIPTION_ID"
```

## Project Structure

```
.
├── README.md                 # This file
├── providers.tf             # Terraform and provider configuration
├── main.tf                  # Main infrastructure resources
├── variables.tf             # Variable definitions
├── outputs.tf               # Output values
├── ssh.tf                   # SSH key management resources
├── backend-config.hcl       # Azure backend configuration
├── init-terraform.sh        # Initialization script
├── .terraform/              # Terraform working directory (generated)
├── .terraform.lock.hcl      # Provider lock file (generated)
├── .gitignore               # Git ignore rules
└── terraform.tfstate*       # State files (stored in Azure)
```

## Variables

Key variables defined in `variables.tf`:

| Variable | Default | Description |
|----------|---------|-------------|
| `resource_group_location` | Central India | Azure region |
| `resource_group_name_prefix` | pt19881rg | Resource group name |
| `virtual_network` | pt1988vnet | VNet name |
| `vm_size` | Standard_B1ls | VM instance type |
| `username` | partha | VM admin username |
| `password` | Kukapilla@1269 | VM admin password |

## Outputs

The configuration outputs:
- `resource_group_name` - Created resource group name
- `public_ip_address` - VM public IP address
- `key_data` - SSH public key (for key-based auth)
- `priv_key_data` - SSH private key

## Resources Created

1. **Resource Group** (`pt19881rg`)
2. **Virtual Network** with subnet
3. **Public IP Address**
4. **Network Security Group** (SSH, HTTP access)
5. **Network Interface**
6. **Storage Account** (boot diagnostics)
7. **Linux Virtual Machine** (Ubuntu 22.04)
8. **SSH Key Pair** (Azure-managed)

## Troubleshooting

### Error: "Error acquiring the state lock"
Use `-lock=false` flag:
```bash
terraform init -lock=false
terraform plan -lock=false
terraform apply -lock=false
```

### Error: "Backend configuration block has changed"
Reinitialize with reconfigure flag:
```bash
terraform init -backend-config=backend-config.hcl -lock=false -reconfigure
```

### Error: "application was not found in the directory"
Update your Azure provider credentials in `providers.tf` with valid credentials from your new Azure account.

## Clean Up

To destroy all resources:
```bash
terraform destroy -lock=false
```

## References
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Storage Backend](https://www.terraform.io/language/settings/backends/azurerm)
