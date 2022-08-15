resource "azurerm_application_insights" "example" {
  application_type = "other"
  location = azurerm_resource_group.example.location
  name = "${local.prefix}-appinstights"
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_key_vault" "example" {
  name = "${local.prefix}-akv"
  location = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name = "premium"
}

resource "azurerm_data_factory" "example" {
  name                = "${local.prefix}-adf"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_machine_learning_workspace" "example" {
  name                    = "${local.prefix}-aml"
  location                = azurerm_resource_group.example.location
  resource_group_name     = azurerm_resource_group.example.name
  application_insights_id = azurerm_application_insights.example.id
  key_vault_id            = azurerm_key_vault.example.id
  storage_account_id      = azurerm_storage_account.blobaccount.id

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}
