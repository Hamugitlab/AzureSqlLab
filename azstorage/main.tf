resource "azurerm_storage_account" "storage_account2" {
  resource_group_name      = azurerm_resource_group.rg2.name
  name                     = "backend${lower(random_id.id.hex)}"
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_queue" "storage_queue" {
  storage_account_name = azurerm_storage_account.storage_account2.name
  name                 = "queue"
}

resource "random_id" "id" {
  byte_length = 8
}

resource "azurerm_storage_container" "storage_container" {
  storage_account_name  = azurerm_storage_account.storage_account2.name
  name                  = "blob"
  container_access_type = "private"
}

resource "azurerm_resource_group" "rg2" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_storage_blob" "storage_blob" {
  type                   = "Block"
  storage_container_name = azurerm_storage_container.storage_account2.name
  storage_account_name   = azurerm_storage_account.storage_account2.name
  name                   = "backend"
}

