resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "app" {
  name                 = "app-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "data" {
  name                 = "data-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "private-endpoint-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_network_security_group" "app_nsg" {
  name                = "app-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_group" "data_nsg" {
  name                = "data-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_rule" "data_allow_app" {
  name                        = "allow-app-to-data"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"

  source_address_prefix       = "10.0.1.0/24"
  source_port_range           = "*"
  destination_address_prefix  = "10.0.2.0/24"
  destination_port_range      = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.data_nsg.name
}

resource "azurerm_network_security_rule" "data_deny_all" {
  name                        = "deny-all-inbound"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"

  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.data_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "app_assoc" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "data_assoc" {
  subnet_id                 = azurerm_subnet.data.id
  network_security_group_id = azurerm_network_security_group.data_nsg.id
}

resource "azurerm_private_endpoint" "storage_pe" {
  name                = "pe-storage"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "storage-connection"
    private_connection_resource_id = var.storage_account_id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "default"

    private_dns_zone_ids = [
      azurerm_private_dns_zone.blob.id
    ]
  }
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  name                  = "dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

resource "azurerm_network_security_rule" "allow_dns_outbound" {
  name                        = "allow-dns-outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"

  source_address_prefix       = "*"
  source_port_range           = "*"

  destination_address_prefix  = "AzureDNS"
  destination_port_range      = "53"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.app_nsg.name
}

resource "azurerm_network_security_rule" "allow_dns_outbound_data" {
  name                        = "allow-dns-outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"

  source_address_prefix       = "*"
  source_port_range           = "*"

  destination_address_prefix  = "AzureDNS"
  destination_port_range      = "53"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.data_nsg.name
}

resource "azurerm_network_security_rule" "allow_azure_outbound" {
  name                        = "allow-azure-outbound"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"

  source_address_prefix       = "*"
  source_port_range           = "*"

  destination_address_prefix  = "AzureCloud"
  destination_port_range      = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.app_nsg.name
}

resource "azurerm_network_security_rule" "allow_azure_outbound_data" {
  name                        = "allow-azure-outbound"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"

  source_address_prefix       = "*"
  source_port_range           = "*"

  destination_address_prefix  = "AzureCloud"
  destination_port_range      = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.data_nsg.name
}

resource "azurerm_network_security_rule" "deny_all_outbound" {
  name                        = "deny-all-outbound"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"

  source_address_prefix       = "*"
  source_port_range           = "*"

  destination_address_prefix  = "*"
  destination_port_range      = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.app_nsg.name
}

resource "azurerm_network_security_rule" "deny_all_outbound_data" {
  name                        = "deny-all-outbound"
  priority                    = 200
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"

  source_address_prefix       = "*"
  source_port_range           = "*"

  destination_address_prefix  = "*"
  destination_port_range      = "*"

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.data_nsg.name
}