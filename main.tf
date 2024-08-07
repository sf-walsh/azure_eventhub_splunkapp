# https://lantern.splunk.com/Data_Descriptors/Microsoft/Getting_started_with_Microsoft_Azure_Event_Hub_data

# data filter for current subscription
data "azurerm_subscription" "current" {}
data "azuread_client_config" "current" {}


locals {
  name            = "${var.application}-${var.ado}-${var.environment}"
  tags = {
    Name      = local.name
    Location  = var.location
    Terraform = true
  }
}

# Create the prod resource group
resource "azurerm_resource_group" "splunk" {
  name     = "${local.name}-splunk.rg"
  location = var.location

  tags = local.tags
}

########################
## Steps are based on the article linked at the top
########################

##### Step 1 - Create an Event Hub Namespace

# Create an eventhub
resource "azurerm_eventhub" "splunk" {
  name                = "${local.name}-eventhub"
  namespace_name      = azurerm_eventhub_namespace.splunk.name
  resource_group_name = azurerm_resource_group.splunk.name
  partition_count     = 32
  message_retention   = 1
}

# Create an eventhub namespace
resource "azurerm_eventhub_namespace" "splunk" {
  name                = "${local.name}-namespace"
  location            = var.location
  resource_group_name = azurerm_resource_group.splunk.name
  sku                 = "Standard"
  zone_redundant = false

  tags = local.tags
}

resource "azurerm_eventhub_namespace_authorization_rule" "splunk" {
  name                = "${local.name}-splunk-auth-rule"
  namespace_name      = azurerm_eventhub_namespace.splunk.name
  resource_group_name = azurerm_resource_group.splunk.name
  listen              = true
  send                = true
  manage              = true
}

##### Step 2 - Send data to an Event Hub

# Create the diagnostic settings - config to send to Event Hub (Splunk)
resource "azurerm_monitor_diagnostic_setting" "splunk" {
  name               = "${local.name}-splunk-diagnostics"
  target_resource_id = data.azurerm_subscription.current.id
  eventhub_name = azurerm_eventhub.splunk.name
  eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.splunk.id

  log {
    category = "Administrative"
  }
  
  log {
    category = "Security"
  }

  log {
    category = "ServiceHealth"
  }

  log {
    category = "Alert"
  }

  log {
    category = "Recommendation"
  }

  log {
    category = "Policy"
  }

  log {
    category = "Autoscale"
  }

  log {
    category = "ResourceHealth"
  }
}

##### Step 3 & 4
## - Set up authentication (and an app)
## - Set up role assignments

######################
# Application
######################

resource "azuread_application" "splunk" {
  display_name     = "${local.name}-splunk-app"
  owners           = [data.azuread_client_config.current.object_id]

}

resource "azuread_application_password" "splunk" {
  display_name = "${local.name}-splunk-secret"
  application_object_id = azuread_application.splunk.object_id
  end_date              = "2040-01-01T01:02:03Z"
}


resource "azuread_service_principal" "splunk" {
  application_id = azuread_application.splunk.application_id
}

resource "azurerm_role_assignment" "splunk" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = azuread_service_principal.splunk.object_id
}