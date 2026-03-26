# Network Design — Networking Decisions

## Access Model

- Private endpoint used for secure storage access
- Public access to storage account restricted to trusted IP for terraform ops

## Constraints

- Terraform executed outside of VNet
- Full private-only requires moving terraform within vnet

## DNS Behavior

- Private DNS zone ensures internal resolution
- Validation requires in-VNet client (compute will be added later)

## Outbound Gap

- AzureCloud still allowed
- ToDo: controlled egress through firewall or NAT

## Terraform Implementation (Key Snippets)

```hcl

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

```
```hcl

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

```
```hcl

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

```


## Architecture Evidence

![VNet](./images/vnet.png)
![Subnets](./images/subnets.png)
![App NSG](./images/nsg-rules-app.png)
![Data NSG](./images/nsg-rules-data.png)
![Private Endpoint](./images/private-endpoint.png)
![Storage Networking](./images/storage-networking.png)