variable "rgfirewall" {
  type        = string
}

variable "idFrontEndSbn" {
  type        = string
}
variable "sbw10" {
  type        = string
}
variable "rgw10" {
  type        = string
}

variable "idBackEndSbn" {
  type        = string
}
variable "loc"{
    type        = string
}

variable "fwfrontprvip" {
  type        = string
}

variable "fwbackprvip" {
  type        = string
}
variable "FrontEndSubnetprefix" {
  type        = string
}
variable "BackEndSubnetprefix" {
  type        = string
}

variable "w10Subnetprefix" {
  type        = string
}

resource "azurerm_route_table" "rtFrontend" {
  name                          = "rtFrontend"
  location = var.loc
  resource_group_name           = var.rgfirewall
  disable_bgp_route_propagation = true
/*
  route {
    name           = "TraficolocalFront"
    address_prefix = azurerm_subnet.FrontEndSubnet.address_prefix
    next_hop_type  = "vnetlocal"
  }*/
  route {
    name           = "Sobrescribir_por_defecto"
    address_prefix = var.FrontEndSubnetprefix
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address =var.fwfrontprvip
  }
  tags = {
    environment = "Production"
  }
}

resource "azurerm_route_table" "rtBackend" {
  name                          = "rtBackend"
  location                      = var.loc
  resource_group_name           = var.rgfirewall
  disable_bgp_route_propagation = true
/*
  route {
    name           = "traficolocalBack"
    address_prefix = azurerm_subnet.BackEndSubnet.address_prefix
    next_hop_type  = "vnetlocal"
  }
  */
  route {
    name           = "HaciaCheckpoint"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address =var.fwbackprvip #azurerm_network_interface.nic_firewall_back.private_ip_address
  }
    route {
    name           = "Sobrescribir_por_defecto"
    address_prefix = var.BackEndSubnetprefix
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address =var.fwbackprvip
  }

  route {
    name           = "Acceso_a_maquina"
    address_prefix = "81.0.33.135/32"
    next_hop_type  = "Internet"
  }

  tags = {
    environment = "Production"
  }
}

# Tabla de rutas para el w10
resource "azurerm_route_table" "rtsbw10" {
  name                          = "rtsbw10"
  location                      = var.loc
  resource_group_name           = var.rgw10
  disable_bgp_route_propagation = true
  route {
    name           = "HaciaCheckpoint"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = var.fwbackprvip
  }
    route {
    name           = "Sobrescribir_por_defecto"
    address_prefix = var.w10Subnetprefix
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address =var.fwbackprvip
  }
  
  route {
    name           = "Acceso_a_maquina"
    address_prefix = "81.0.33.135/32"
    next_hop_type  = "Internet"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet_route_table_association" "asociacion" {
  subnet_id      = var.idBackEndSbn
  route_table_id = azurerm_route_table.rtBackend.id
}

resource "azurerm_subnet_route_table_association" "asociacion2" {
  subnet_id      = var.idFrontEndSbn
  route_table_id = azurerm_route_table.rtFrontend.id

}

resource "azurerm_subnet_route_table_association" "asociacion3" {
  subnet_id      = var.sbw10
  route_table_id = azurerm_route_table.rtsbw10.id

}





























