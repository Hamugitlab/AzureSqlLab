$resourceGroupName = "HimResourceGroup"
$managedInstance = "himinname"
$resourceGroup = "HimResourceGroup"


# Connect-AzAccount
# The SubscriptionId in which to create these objects
# $SubscriptionId = ''
# Set the resource group name and location for your managed instance
$resourceGroupName = "HimResourceGroup-$(Get-Random)"
$location = "eastus2"
# Set the networking values for your managed instance
$vNetName = "HimVnet-$(Get-Random)"
$vNetAddressPrefix = "10.1.0.0/16"
$defaultSubnetName = "HimDefaultSubnet-$(Get-Random)"
$defaultSubnetAddressPrefix = "10.0.0.0/24"
$miSubnetName = "HimMISubnet-$(Get-Random)"
$miSubnetAddressPrefix = "10.0.0.0/24"
#Set the managed instance name for the new managed instance
$instanceName = "himminame-$(Get-Random)"
# Set the admin login and password for your managed instance
$miAdminSqlLogin = "SqlAdmin"
$miAdminSqlPassword = "Azure1234567!12345"
# Set the managed instance service tier, compute level, and license mode
$edition = "General Purpose"
$vCores = 4
$maxStorage = 32
$computeGeneration = "Gen5"
$license = "LicenseIncluded" #"BasePrice" or LicenseIncluded if you have don't have SQL Server licence that can be used for AHB discount
