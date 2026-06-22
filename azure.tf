# Azure Resource Group
resource "azurerm_resource_group" "xray-rg" {
  name     = "xray-resources"
  location = "West Europe"

  tags = {
    Owner       = "Aleksandr Andreichenko"
    Environment = "Production"
  }
}

# Azure Virtual Network & Subnet
resource "azurerm_virtual_network" "xray-vnet" {
  name                = "xray-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.xray-rg.location
  resource_group_name = azurerm_resource_group.xray-rg.name
}

resource "azurerm_subnet" "xray-subnet" {
  name                 = "xray-subnet"
  resource_group_name  = azurerm_resource_group.xray-rg.name
  virtual_network_name = azurerm_virtual_network.xray-vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

# Azure Public IP for Load Balancer
resource "azurerm_public_ip" "xray-lb-ip" {
  name                = "xray-lb-ip"
  location            = azurerm_resource_group.xray-rg.location
  resource_group_name = azurerm_resource_group.xray-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Azure Load Balancer (Equivalent to AWS NLB)
resource "azurerm_lb" "xray-lb" {
  name                = "xray-lb"
  location            = azurerm_resource_group.xray-rg.location
  resource_group_name = azurerm_resource_group.xray-rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "xray-frontend-ip"
    public_ip_address_id = azurerm_public_ip.xray-lb-ip.id
  }
}

# Backend Address Pool for Load Balancer
resource "azurerm_lb_backend_address_pool" "xray-pool" {
  loadbalancer_id = azurerm_lb.xray-lb.id
  name            = "xray-backend-pool"
}

# Load Balancer Probe (Health Check)
resource "azurerm_lb_probe" "xray-probe" {
  loadbalancer_id = azurerm_lb.xray-lb.id
  name            = "xray-health-probe"
  port            = var.xray_port
  protocol        = "Tcp"
  interval_in_seconds = 15
  number_of_probes    = 2
}

# Load Balancer Rule (Equivalent to Listener & Target Group Action)
resource "azurerm_lb_rule" "xray-rule" {
  loadbalancer_id                = azurerm_lb.xray-lb.id
  name                           = "xray-lb-rule"
  protocol                       = "Tcp"
  frontend_port                  = var.xray_port
  backend_port                   = var.xray_port
  frontend_ip_configuration_name = "xray-frontend-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.xray-pool.id]
  probe_id                       = azurerm_lb_probe.xray-probe.id
}

# Network Security Group
resource "azurerm_network_security_group" "xray-nsg" {
  name                = "xray-nsg"
  location            = azurerm_resource_group.xray-rg.location
  resource_group_name = azurerm_resource_group.xray-rg.name

  security_rule {
    name                       = "allow-xray-port"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = tostring(var.xray_port)
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-ssh"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "xray-nsg-assoc" {
  subnet_id                 = azurerm_subnet.xray-subnet.id
  network_security_group_id = azurerm_network_security_group.xray-nsg.id
}

# Linux Virtual Machine Scale Set (Equivalent to AWS Launch Template + ASG)
resource "azurerm_linux_virtual_machine_scale_set" "xray-vmss" {
  name                = "xray-vmss"
  resource_group_name = azurerm_resource_group.xray-rg.name
  location            = azurerm_resource_group.xray-rg.location
  sku                 = "Standard_B1s" # Economical size, suitable for lightweight VPN proxy
  instances           = var.asg_desired_capacity
  admin_username      = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
    disk_size_gb         = 30
  }

  network_interface {
    name    = "xray-nic"
    primary = true

    ip_configuration {
      name                                   = "xray-ip-config"
      primary                                = true
      subnet_id                              = azurerm_subnet.xray-subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.xray-pool.id]
      
      public_ip_address {
        name = "xray-pip"
      }
    }
  }

  # Automated bootstrapping of Xray service on Ubuntu Scale Set
  custom_data = base64encode(<<-EOF
                #!/bin/bash
                apt-get update -y
                apt-get install -y curl
                # Install Xray via official release script
                bash <(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)
                systemctl enable xray
                systemctl start xray
                EOF
  )

  tags = {
    Owner       = "Aleksandr Andreichenko"
    Environment = "Production VPN"
  }
}

# Autoscale Setting for VMSS (Equivalent to AWS ASG Scaling Policy)
resource "azurerm_monitor_autoscale_setting" "xray-autoscale" {
  name                = "xray-autoscale-setting"
  resource_group_name = azurerm_resource_group.xray-rg.name
  location            = azurerm_resource_group.xray-rg.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.xray-vmss.id

  profile {
    name = "defaultProfile"

    capacity {
      default = tostring(var.asg_desired_capacity)
      minimum = tostring(var.asg_min_size)
      maximum = tostring(var.asg_max_size)
    }

    # Scale out rule: CPU usage > 70% for 5 minutes
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.xray-vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    # Scale in rule: CPU usage < 30% for 5 minutes
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.xray-vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}

# Azure outputs for connection
output "az_xray_lb_public_ip" {
  description = "The public IP of the Azure Load Balancer routing traffic to Xray VMSS"
  value       = azurerm_public_ip.xray-lb-ip.ip_address
}
