output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}
output "app_subnet_id" {
  value = azurerm_subnet.app.id
}
output "data_subnet_id" {
  value = azurerm_subnet.data.id
}
output "private_endpoint_subnet_id" {
  value = azurerm_subnet.private_endpoints.id
}