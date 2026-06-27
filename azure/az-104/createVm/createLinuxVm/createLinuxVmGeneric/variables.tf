variable "resource_group_location" {
  type        = string
  default     = "Central India"
  description = "Location of the resource group."
}

variable "resource_group_name_prefix" {
  type        = string
  default     = "my-rg"
  description = "Prefix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}

variable "virtual_network" {
  default	= "my-vnet"
}

variable "vnet_address_space" {
  description = "The address space that is used by the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "virtual_network_subnet" {
  default	= "pt1988vnet-subnet-1"
}

variable "vnet_subnet-1-address_space" {
  description = "The address space that is used by the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/24"]
}

variable "public_ip" {
  default	= "pt19881-pub-ip"
}

variable "nsg_name" {
  default	= "pt19881-nsg"
}

variable "nic_name" {
  default	= "pt19881-nic"
}

variable "nic_config" {
  default	= "pt19881-nic-config"
}

variable "vm_size" {
  default	= "Standard_B1ls"
}

variable "os_disk_name" {
  default	= "pt19881OsDisk"
}

variable "username" {
  type        = string
  description = "The username for the local account that will be created on the new VM."
  default     = "partha"
}

variable password {
  default     = "Kukapilla@1269"
}

variable scfile{
    type = string
    default = "nginx.sh"
}
