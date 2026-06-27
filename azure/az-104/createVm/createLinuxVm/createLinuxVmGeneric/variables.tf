variable "resource_group_location" {
  type        = string
  default     = "Central India"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "rg-pa883-prod-01"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "virtual_network" {
  default	= "vnet-pa883-prod-01"
}

variable "vnet_address_space" {
  description = "The address space that is used by the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "virtual_network_subnet" {
  default	= "subnet-pa883-prod-01"
}

variable "vnet_subnet_1_address_space" {
  description = "The address space that is used by the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/24"]
}

variable "public_ip" {
  default	= "public-ip-pa883-prod-01"
}

variable "nsg_name" {
  default	= "nsg-pa883-prod-01"
}

variable "nic_name" {
  default	= "nic-pa883-prod-01"
}

variable "nic_config" {
  default	= "nic-config-pa883-prod-01"
}

variable "vm_size" {
  default	= "Standard_B1ls"
}

variable "os_disk_name" {
  default	= "os-disk-pa883-prod-01"
}

variable "username" {
  type        = string
  description = "The username for the local account that will be created on the new VM."
  default     = "partha"
}

variable scfile{
    type = string
    default = "nginx.sh"
}
