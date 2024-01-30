# Suppress networking breaking changes warning (https://aka.ms/azps-changewarnings
Set-Item Env:\SuppressAzurePowerShellBreakingChangeWarnings "true"

# Set the subscription context

# Show randomized variables
Write-host "Subscription name is"  $subscriptionId 
Write-host "Resource group name is" $resourceGroupName
Write-host "Password is" $secpasswd
Write-host "Primary Virtual Network name is" $primaryVNet
Write-host "Primary default subnet name is" $primaryDefaultSubnet
Write-host "Primary SQL Managed Instance subnet name is" $primaryMiSubnetName
Write-host "Secondary Virtual Network name is" $secondaryVNet
Write-host "Secondary default subnet name is" $secondaryDefaultSubnet
Write-host "Secondary SQL Managed Instance subnet name is" $secondaryMiSubnetName
Write-host "Primary SQL Managed Instance name is" $primaryInstance
Write-host "Secondary SQL Managed Instance name is" $secondaryInstance
Write-host "Failover group name is" $failoverGroupName

Set-AzContext -SubscriptionId $subscriptionId 

# Create the resource group
Write-host "Creating resource group..."
$resourceGroup = New-AzResourceGroup -Name $resourceGroupName -Location $location -Tag @{Owner="SQLDB-Samples"}
$resourceGroup