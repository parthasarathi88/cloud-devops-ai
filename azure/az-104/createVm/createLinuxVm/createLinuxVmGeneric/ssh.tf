resource "random_pet" "ssh_key_name" {
  prefix    = "ssh"
  separator = ""
}

# Use the existing public key for VM authentication.
locals {
  public_key_path  = "${path.module}/pvt-key.pub"
}

# Read the existing public key file
data "local_file" "public_key" {
  filename = local.public_key_path
}

# Create SSH public key resource with the existing public key
resource "azurerm_ssh_public_key" "ssh_key" {
  name                = random_pet.ssh_key_name.id
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  public_key          = data.local_file.public_key.content
}

output "key_data" {
  value       = azurerm_ssh_public_key.ssh_key.public_key
  description = "SSH public key from pvt-key.pub"
}

output "ssh_key_id" {
  value       = azurerm_ssh_public_key.ssh_key.id
  description = "Azure SSH public key resource ID"
}
