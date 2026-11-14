terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "prefix" {
  type    = string
  default = "upt-neo4j-lab04"
}

variable "location" {
  type    = string
  default = "eastus2"
}

variable "neo4j_password" {
  type      = string
  sensitive = true
}

variable "image_name" {
  type = string
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "registry_username" {
  type = string
}

variable "registry_password" {
  type      = string
  sensitive = true
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.prefix}"
  location = var.location
}

resource "azurerm_container_group" "neo4j" {
  name                = "${var.prefix}-neo4j"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  ip_address_type     = "Public"
  dns_name_label      = "${var.prefix}-neo4j"

  container {
    name   = "neo4j"
    image  = "neo4j:5"
    cpu    = "1"
    memory = "2"

    ports {
      port     = 7474
      protocol = "TCP"
    }

    ports {
      port     = 7687
      protocol = "TCP"
    }

    secure_environment_variables = {
      NEO4J_AUTH = "neo4j/${var.neo4j_password}"
    }
  }
}

resource "azurerm_service_plan" "plan" {
  name                = "plan-${var.prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "api" {
  name                = "${var.prefix}-api"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    always_on = true
    application_stack {
      docker_image_name        = "${var.image_name}:${var.image_tag}"
      docker_registry_url      = "https://ghcr.io"
      docker_registry_username = var.registry_username
      docker_registry_password = var.registry_password
    }
  }

  app_settings = {
    WEBSITES_PORT                = "8080"
    "neo4jdb__NEO4J_URI"         = "bolt://${azurerm_container_group.neo4j.fqdn}:7687"
    "neo4jdb__NEO4J_USER"        = "neo4j"
    "neo4jdb__NEO4J_PASSWORD"    = var.neo4j_password
  }
}

output "neo4j_bolt_uri" {
  value = "bolt://${azurerm_container_group.neo4j.fqdn}:7687"
}

output "neo4j_browser_url" {
  value = "http://${azurerm_container_group.neo4j.fqdn}:7474"
}

output "webapp_url" {
  value = "https://${azurerm_linux_web_app.api.default_hostname}"
}

output "webapp_name" {
  value = azurerm_linux_web_app.api.name
}

output "resource_group" {
  value = azurerm_resource_group.rg.name
}
