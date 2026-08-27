terraform {
  required_version = ">=0.12"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>1.5"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  # Azure credentials from environment variables (recommended for security)
  # Set these in your environment before running Terraform:
  #   export ARM_CLIENT_ID="your-client-id"
  #   export ARM_CLIENT_SECRET="your-client-secret"
  #   export ARM_TENANT_ID="your-tenant-id"
  #   export ARM_SUBSCRIPTION_ID="your-subscription-id"
  #
  # The provider will automatically pick up these variables
  # and you don't need to specify them here
}
