rgs = {
  projectrg = "west us"
}
Vnets = {
  vnet1 = {
   name = "hubvnet"
  location = "west us"
  resource_group_name = "projectrg"
  address_space = ["10.0.0.0/16"]
     }
  vnet2 = {
   name = "spokevnet"
  location = "west us"
  resource_group_name = "projectrg"
  address_space = ["192.168.0.0/24"]
  }
}

subnets = {
  subnet1 = {
    name = "AzureBastionSubnet"
    resource_group_name ="projectrg"
    vnet_name = "vnet1"
   address_prefixes = ["10.0.5.0/26"]
    
  }
  subnet2 = {
    name = "Appsubnet"
    resource_group_name ="projectrg"
    vnet_name = "vnet2"
   address_prefixes = ["192.168.0.32/27"]
    
  }
}
vnetpeering1 = {
  vnetpeer1 ={
          name ="peerhubtospoke"
  resource_group_name ="projectrg"
  vnet_name = "vnet1"
  remote_vnet_name ="vnet2"
  }
}
vnetpeering2 ={
  vnetpeer2 ={
          name ="peerspoketohub"
  resource_group_name ="projectrg"
  vnet_name = "vnet2"
  remote_vnet_name ="vnet1"
  }
}
nics = {
  NIC1 = {
    name = "Inerface1"
    location ="west us"
    resource_group_name = "projectrg"
    ip_configuration ={
    name        = "interfaceipVM1"
    subnet_id   = "subnet2"
    
  }
  }
   NIC2 = {
    name = "Inerface2"
    location ="west us"
    resource_group_name = "projectrg"
    ip_configuration ={
    name        = "interfaceipVM1"
    subnet_id   = "subnet2"
    
  }
  }

}
vms = {
  VM1 = {
name                = "AppVM1"
  resource_group_name = "projectrg"
  location            = "west us"
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser1"
  admin_password = "Amroha@12345"
  interface_ids = "NIC1"

  }

  VM2 = {
name                = "AppVM2"
  resource_group_name = "projectrg"
  location            = "west us"
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser2"
  admin_password = "Amroha@12345"
  interface_ids = "NIC2"

  }
}
publicip = {
  IP = {
    name = "ipofbastion"
    location="west us"
    resource_group_name = "projectrg"

  }
  NATIP = {
    name = "ipfornatgateway"
    location="west us"
    resource_group_name = "projectrg"
  }

}
bastion = {
  bastion_host ={
     name                = "Bastionhost"
  location            = "west us"
  resource_group_name ="projectrg"
  ip_configuration= {
    name                 = "bastionip"
    subnet_id            = "subnet1"
    address_id = "IP"
  }
  }
}
NSGs = {
  NSG1 = {
    name ="nsgappsubnet"
    location = "west us"
    resource_group_name ="projectrg"
  }
}
nsgassociate = {
  nsgass ={
    subnet_id = "subnet2"
    NSG_id = "NSG1"
  }
}
NATgateway = {
  nat1 = {
    name     = "natgatewayforappsubnet"
  location     = "west us"
  resource_group_name = "projectrg"
  }
}
natpublicipass = {
  natip1 ={
     nat_gateway_id = "nat1"
     public_ip_address_id= "NATIP"
  }
}
natsubnet = {
   natsubnet1 ={
    subnet_id = "subnet2"
    nat_gateway_id = "nat1"
   }
}