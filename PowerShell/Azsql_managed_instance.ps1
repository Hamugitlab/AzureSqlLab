#  Remove-AzResourceGroup -ResourceGroupName 'HimResourceGroup-1350475815'


$NSnetworkModels = "Microsoft.Azure.Commands.Network.Models"
$NScollections = "System.Collections.Generic"

# Connect-AzAccount
# The SubscriptionId in which to create these objects
# $SubscriptionId = ''
# Set the resource group name and location for your managed instance
$resourceGroupName = "HimResourceGroup-$(Get-Random)"
$location = "eastus2"
# Set the networking values for your managed instance
$vNetName = "HimVnet-$(Get-Random)"
$vNetAddressPrefix = "10.0.0.0/16"
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

# Set subscription context
# Set-AzContext -SubscriptionId $SubscriptionId 

# Create a resource group
$resourceGroup = New-AzResourceGroup -Name $resourceGroupName -Location $location -Tag @{Owner="SQLDB-Samples"}

# Configure virtual network, subnets, network security group, and routing table
$networkSecurityGroupMiManagementService = New-AzNetworkSecurityGroup `
-Name 'HimNetworkSecurityGroupMiManagementService' `
-ResourceGroupName $resourceGroupName `
-location $location

$routeTableMiManagementService = New-AzRouteTable `
 -Name 'HimRouteTableMiManagementService' `
 -ResourceGroupName $resourceGroupName `
 -location $location

$virtualNetwork = New-AzVirtualNetwork `
 -ResourceGroupName $resourceGroupName `
 -Location $location `
 -Name $vNetName `
 -AddressPrefix $vNetAddressPrefix

                  Add-AzVirtualNetworkSubnetConfig `
 -Name $miSubnetName `
                   -VirtualNetwork $virtualNetwork `
 -AddressPrefix $miSubnetAddressPrefix `
 -NetworkSecurityGroup $networkSecurityGroupMiManagementService `
 -RouteTable $routeTableMiManagementService |
                  Set-AzVirtualNetwork

$virtualNetwork = Get-AzVirtualNetwork -Name $vNetName -ResourceGroupName $resourceGroupName

$subnet= $virtualNetwork.Subnets[0]

# Create a delegation
$subnet.Delegations = New-Object "$NScollections.List``1[$NSnetworkModels.PSDelegation]"
$delegationName = "dgManagedInstance" + (Get-Random -Maximum 1000)
$delegation = New-AzDelegation -Name $delegationName -ServiceName "Microsoft.Sql/managedInstances"
$subnet.Delegations.Add($delegation)

Set-AzVirtualNetwork -VirtualNetwork $virtualNetwork

$miSubnetConfigId = $subnet.Id



$allowParameters = @{
    Access = 'Allow'
    Protocol = 'Tcp'
    Direction= 'Inbound'
    SourcePortRange = '*'
    SourceAddressPrefix = 'VirtualNetwork'
    DestinationAddressPrefix = '*'
}
$denyInParameters = @{
    Access = 'Deny'
    Protocol = '*'
    Direction = 'Inbound'
    SourcePortRange = '*'
    SourceAddressPrefix = '*'
    DestinationPortRange = '*'
    DestinationAddressPrefix = '*'
}
$denyOutParameters = @{
    Access = 'Deny'
    Protocol = '*'
    Direction = 'Outbound'
    SourcePortRange = '*'
    SourceAddressPrefix = '*'
    DestinationPortRange = '*'
    DestinationAddressPrefix = '*'
}

Get-AzNetworkSecurityGroup `
        -ResourceGroupName $resourceGroupName `
        -Name "HimNetworkSecurityGroupMiManagementService" |
    Add-AzNetworkSecurityRuleConfig `
        @allowParameters `
        -Priority 1000 `
        -Name "allow_tds_inbound" `
        -DestinationPortRange 1433 |
    Add-AzNetworkSecurityRuleConfig `
        @allowParameters `
        -Priority 1100 `
        -Name "allow_redirect_inbound" `
        -DestinationPortRange 11000-11999 |
    Add-AzNetworkSecurityRuleConfig `
        @denyInParameters `
        -Priority 4096 `
        -Name "deny_all_inbound" |
    Add-AzNetworkSecurityRuleConfig `
        @denyOutParameters `
        -Priority 4096 `
        -Name "deny_all_outbound" |
    Set-AzNetworkSecurityGroup


# Create credentials
$secpassword = ConvertTo-SecureString $miAdminSqlPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($miAdminSqlLogin, $secpassword)

# Create managed instance
New-AzSqlInstance -Name $instanceName `
 -ResourceGroupName $resourceGroupName -Location $location -SubnetId $miSubnetConfigId `
 -AdministratorCredential $credential `
 -StorageSizeInGB $maxStorage -VCore $vCores -Edition $edition `
 -ComputeGeneration $computeGeneration -LicenseType $license

# Clean up deployment 
# Remove-AzResourceGroup -ResourceGroupName $resourceGroupName