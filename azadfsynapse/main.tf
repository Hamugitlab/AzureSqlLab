resource "azurerm_data_factory_linked_service_key_vault" "adf_linked_service_kv" {
  name            = "kvlink"
  key_vault_id    = azurerm_key_vault.pe3.id
  data_factory_id = azurerm_data_factory.vnet.id
}

resource "azurerm_subnet" "snet" {
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  name                 = "snet_storage"

  address_prefixes = [
    "10.0.3.0/24",
  ]
}

resource "azurerm_subnet" "snet2" {
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  name                 = "snet_appservice"

  address_prefixes = [
    "10.0.5.0/24",
  ]
}

resource "azurerm_data_factory_integration_runtime_azure" "adf_integration_runtime_azure" {
  name            = "integrationruntime001"
  location        = var.location
  data_factory_id = azurerm_data_factory.vnet.id
}

resource "azurerm_virtual_network" "vnet" {
  tags                = merge(var.tags, {})
  resource_group_name = azurerm_resource_group.rg.name
  name                = var.vnet_name
  location            = var.location

  address_space = [
    var.vnet_cidr,
  ]
}

resource "azurerm_key_vault" "kv" {
  tenant_id                   = data.azurerm_client_config.client_config.tenant_id
  tags                        = merge(var.tags, {})
  soft_delete_retention_days  = 7
  sku_name                    = "standard"
  resource_group_name         = azurerm_resource_group.rg.name
  purge_protection_enabled    = false
  name                        = "adfkv"
  location                    = var.location
  enabled_for_disk_encryption = true

  access_policy {
    tenant_id = data.azurerm_client_config.client_config.tenant_id
    object_id = data.azurerm_client_config.client_config.object_id
    key_permissions = [
      "Get",
      "List",
      "Recover",
      "Delete",
      "Purge",
      "Restore",
    ]
    secret_permissions = [
      "Get",
      "List",
      "Purge",
      "Recover",
      "Set",
    ]
    storage_permissions = [
      "Get",
      "List",
    ]
  }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

resource "azurerm_private_endpoint" "pe" {
  tags                = merge(var.tags, {})
  subnet_id           = azurerm_subnet.pe2.id
  resource_group_name = azurerm_resource_group.rg.name
  name                = "sql_server_pe"
  location            = var.location

  private_service_connection {
    private_connection_resource_id = azurerm_mssql_server.mssql_server.id
    name                           = "sql_server_pe"
    is_manual_connection           = false
    subresource_names = [
      "mysqlServer",
    ]
  }
}

resource "azurerm_mssql_server" "mssql_server" {
  version                       = "12.0"
  tags                          = merge(var.tags, {})
  resource_group_name           = azurerm_resource_group.rg.name
  public_network_access_enabled = false
  name                          = var.sql_server_name
  minimum_tls_version           = "1.2"
  location                      = var.location
  administrator_login_password  = var.adminpassword
  administrator_login           = var.admin_user
}

resource "azurerm_data_factory" "adf" {
  tags                   = merge(var.tags, {})
  resource_group_name    = azurerm_resource_group.rg.name
  public_network_enabled = false
  name                   = var.adf_name
  location               = var.location
}

resource "azurerm_resource_group" "rg" {
  tags     = merge(var.tags, {})
  name     = var.rg_name
  location = var.location
}

resource "azurerm_management_lock" "mgt_lock" {
  scope      = azurerm_resource_group.rg.id
  name       = "canDeleteRG"
  lock_level = "CanNotDelete"
}

resource "azurerm_storage_data_lake_gen2_path" "storage_data_lake_gen2_path" {
  storage_account_id = azurerm_storage_account.vnet.id
  resource           = "directory"
  path               = "storagepath"
  filesystem_name    = azurerm_storage_data_lake_gen2_filesystem.vnet.name
}

resource "azurerm_mssql_database" "mssql_db" {
  tags         = merge(var.tags, {})
  sku_name     = "S0"
  server_id    = azurerm_mssql_server.mssql_server.id
  name         = "acctest-db-d"
  license_type = "LicenseIncluded"
  collation    = "SQL_Latin1_General_CP1_CI_AS"
}

data "azurerm_client_config" "client_config" {
}

resource "azurerm_subnet" "snet3" {
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  name                 = "snet_db"

  address_prefixes = [
    "10.0.2.0/24",
  ]
}

resource "azurerm_synapse_workspace" "synapse_workspace" {
  tags                                 = merge(var.tags, {})
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.vnet.id
  sql_administrator_login_password     = var.adminpassword
  sql_administrator_login              = "sqladminuser"
  resource_group_name                  = azurerm_resource_group.rg.name
  name                                 = var.synapse_ws_name
  managed_virtual_network_enabled      = true
  location                             = var.location

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_private_endpoint" "pe2" {
  tags                = merge(var.tags, {})
  subnet_id           = azurerm_subnet.pe2.id
  resource_group_name = azurerm_resource_group.rg.name
  name                = "func_app_pe"
  location            = var.location

  private_service_connection {
    private_connection_resource_id = azurerm_linux_function_app.vnet.id
    name                           = "func_app_pe"
    is_manual_connection           = true
    subresource_names = [
      "sites",
    ]
  }
}

resource "azurerm_data_factory_linked_service_sql_server" "adf_linked_service_sql_server" {
  name              = "adf_to_mssql_connect"
  data_factory_id   = azurerm_data_factory.vnet.id
  connection_string = "Server=tcp:${azurerm_mssql_server.mssql_server.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.mssql_db.name};Persist Security Info=False;User ID=${azurerm_mssql_server.mssql_server.administrator_login};Password=${azurerm_mssql_server.mssql_server.administrator_login_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

  depends_on = [
    azurerm_mssql_server.mssql_server,
  ]

  key_vault_password {
    secret_name         = "secret"
    linked_service_name = azurerm_data_factory_linked_service_key_vault.adf_linked_service_kv.name
  }
}

resource "azurerm_storage_account" "storage_account" {
  tags                     = merge(var.tags, {})
  resource_group_name      = azurerm_resource_group.rg.name
  name                     = var.storage_account_name
  min_tls_version          = "TLS1_2"
  location                 = var.location
  is_hns_enabled           = true
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "storage_data_lake_gen2_filesystem" {
  storage_account_id = azurerm_storage_account.vnet.id
  name               = var.datalake_fs_name
}

resource "azurerm_subnet" "snet4" {
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  name                 = "snet_adf"

  address_prefixes = [
    "10.0.1.0/24",
  ]
}

resource "azurerm_private_endpoint" "pe3" {
  tags                = merge(var.tags, {})
  subnet_id           = azurerm_subnet.pe2.id
  resource_group_name = azurerm_resource_group.rg.name
  name                = "kv-pe"
  location            = var.location

  private_service_connection {
    private_connection_resource_id = azurerm_key_vault.pe3.id
    name                           = "kv-pe"
    is_manual_connection           = false
    subresource_names = [
      "vault",
    ]
  }
}

resource "azurerm_synapse_sql_pool" "synapse_sql_pool" {
  tags                 = merge(var.tags, {})
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  sku_name             = "DW100c"
  name                 = "demo1sqlpool"
  create_mode          = "Default"
}

resource "azurerm_service_plan" "service_plan" {
  tags                = merge(var.tags, {})
  sku_name            = "P1v2"
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  name                = var.sp_name
  location            = var.location
}

resource "azurerm_subnet" "snet5" {
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  name                 = "snet_pe"

  address_prefixes = [
    "10.0.4.0/24",
  ]
}

resource "azurerm_linux_function_app" "linux_function_app" {
  tags                       = merge(var.tags, {})
  storage_account_name       = azurerm_storage_account.vnet.name
  storage_account_access_key = azurerm_storage_account.vnet.primary_access_key
  service_plan_id            = azurerm_service_plan.service_plan.id
  resource_group_name        = azurerm_resource_group.rg.name
  name                       = var.func_name
  location                   = var.location

  site_config {
    always_on = true
  }
}

resource "azurerm_synapse_managed_private_endpoint" "synapse_managed_pe" {
  target_resource_id   = azurerm_storage_account.vnet.id
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  subresource_name     = "blob"
  name                 = "syn-pe"
}

