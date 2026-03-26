variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "vnet_name" {
  type    = string
  default = "vnet-zero-trust"
}
variable "storage_account_id" {
  type = string
}