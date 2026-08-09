resource "azurerm_resource_group" "RGs" {
    for_each = var.rgs
    name=each.key
  location = each.value
}

resource "azurerm_virtual_network" "Vnets" {
    for_each = var.Vnets
  name = each.value.name
  location = each.value.location
  resource_group_name = each.value.resource_group_name
  address_space = each.value.address_space
  depends_on = [ azurerm_resource_group.RGs ]
}
resource "azurerm_subnet""subnets" {
    for_each = var.subnets
    name = each.value.name
    resource_group_name =each.value.resource_group_name
    virtual_network_name =azurerm_virtual_network.Vnets[each.value.vnet_name].name
    address_prefixes = each.value.address_prefixes
    depends_on = [ azurerm_resource_group.RGs,azurerm_virtual_network.Vnets ]
  
}
resource "azurerm_virtual_network_peering" "vnetpeering1" {
  for_each = var.vnetpeering1
  name                      = each.value.name
  resource_group_name       = each.value.resource_group_name
  virtual_network_name      = azurerm_virtual_network.Vnets[each.value.vnet_name].name
  remote_virtual_network_id = azurerm_virtual_network.Vnets[each.value.remote_vnet_name].id
depends_on = [ azurerm_resource_group.RGs,azurerm_virtual_network.Vnets ]
}

resource "azurerm_virtual_network_peering" "vnetpeering2" {
    for_each = var.vnetpeering2
  name                      = each.value.name
  resource_group_name       = each.value.resource_group_name
  virtual_network_name      = azurerm_virtual_network.Vnets[each.value.vnet_name].name
  remote_virtual_network_id = azurerm_virtual_network.Vnets[each.value.remote_vnet_name].id
depends_on = [ azurerm_resource_group.RGs,azurerm_virtual_network.Vnets ]
}

resource "azurerm_network_interface" "nics" {
    for_each = var.nics
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
depends_on = [ azurerm_resource_group.RGs,azurerm_virtual_network.Vnets,azurerm_subnet.subnets ]
  ip_configuration {
    name                          = each.value.ip_configuration.name
    subnet_id                     = azurerm_subnet.subnets[each.value.ip_configuration.subnet_id].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vms" {
    for_each = var.vms
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  size                = each.value.size
  admin_username      = each.value.admin_username
  admin_password = each.value.admin_password
  disable_password_authentication = false 
  network_interface_ids = [
    azurerm_network_interface.nics[each.value.interface_ids].id
  ]

depends_on = [ azurerm_resource_group.RGs,azurerm_network_interface.nics ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
resource "azurerm_public_ip" "public" {
    for_each = var.publicip
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on = [ azurerm_resource_group.RGs ]
}

resource "azurerm_bastion_host" "bastion" {
    for_each = var.bastion
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {
    name                 = each.value.ip_configuration.name
    subnet_id            = azurerm_subnet.subnets[each.value.ip_configuration.subnet_id].id
    public_ip_address_id = azurerm_public_ip.public[each.value.ip_configuration.address_id].id
  
  }
  depends_on = [ azurerm_resource_group.RGs,azurerm_subnet.subnets,azurerm_public_ip.public ]
}

resource "azurerm_network_security_group" "NSG" {
    for_each = var.NSGs
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
depends_on = [ azurerm_resource_group.RGs ]
  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsgassociate" {
    for_each = var.nsgassociate
  subnet_id                 = azurerm_subnet.subnets[each.value.subnet_id].id
  network_security_group_id = azurerm_network_security_group.NSG[each.value.NSG_id].id
depends_on = [ azurerm_subnet.subnets,azurerm_network_security_group.NSG ]
}
resource "azurerm_nat_gateway" "NATgateway" {
    for_each = var.NATgateway
  name                    = each.value.name
  location                = each.value.location
  resource_group_name     = each.value.resource_group_name
  sku_name                = "Standard"
  depends_on = [ azurerm_resource_group.RGs ]
}
resource "azurerm_nat_gateway_public_ip_association" "natpublicipass" {
    for_each = var.natpublicipass
  nat_gateway_id       = azurerm_nat_gateway.NATgateway[each.value.nat_gateway_id].id
  public_ip_address_id = azurerm_public_ip.public[each.value.public_ip_address_id].id
depends_on = [ azurerm_nat_gateway.NATgateway,azurerm_public_ip.public ]
}

resource "azurerm_subnet_nat_gateway_association" "natgw_subnet" {
    for_each = var.natsubnet
  subnet_id      = azurerm_subnet.subnets[each.value.subnet_id].id
  nat_gateway_id = azurerm_nat_gateway.NATgateway[each.value.nat_gateway_id].id
depends_on = [ azurerm_subnet.subnets,azurerm_nat_gateway.NATgateway ]
}