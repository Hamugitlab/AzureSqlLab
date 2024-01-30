# The SubscriptionId in which to create these objects
$subscriptionId = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
# Create a random identifier to use as subscript for the different resource names
$randomIdentifier = $(Get-Random)
# Set the resource group name and location for SQL Managed Instance
$resourceGroupName = "myResourceGroup-$randomIdentifier"
$location = "eastus"
$drLocation = "southcentralus"

# Set the networking values for your primary managed instance
$primaryVNet = "primaryVNet-$randomIdentifier"
$primaryAddressPrefix = "10.0.0.0/16"
$primaryDefaultSubnet = "primaryDefaultSubnet-$randomIdentifier"
$primaryDefaultSubnetAddress = "10.0.0.0/24"
$primaryMiSubnetName = "primaryMISubnet-$randomIdentifier"
$primaryMiSubnetAddress = "10.0.0.0/24"
$primaryMiGwSubnetAddress = "10.0.255.0/27"
$primaryGWName = "primaryGateway-$randomIdentifier"
$primaryGWPublicIPAddress = $primaryGWName + "-ip"
$primaryGWIPConfig = $primaryGWName + "-ipc"
$primaryGWAsn = 61000
$primaryGWConnection = $primaryGWName + "-connection"


# Set the networking values for your secondary managed instance
$secondaryVNet = "secondaryVNet-$randomIdentifier"
$secondaryAddressPrefix = "10.128.0.0/16"
$secondaryDefaultSubnet = "secondaryDefaultSubnet-$randomIdentifier"
$secondaryDefaultSubnetAddress = "10.128.0.0/24"
$secondaryMiSubnetName = "secondaryMISubnet-$randomIdentifier"
$secondaryMiSubnetAddress = "10.128.0.0/24"
$secondaryMiGwSubnetAddress = "10.128.255.0/27"
$secondaryGWName = "secondaryGateway-$randomIdentifier"
$secondaryGWPublicIPAddress = $secondaryGWName + "-IP"
$secondaryGWIPConfig = $secondaryGWName + "-ipc"
$secondaryGWAsn = 62000
$secondaryGWConnection = $secondaryGWName + "-connection"

# Set the SQL Managed Instance name for the new managed instances
$primaryInstance = "primary-mi-$randomIdentifier"
$secondaryInstance = "secondary-mi-$randomIdentifier"

# Set the admin login and password for SQL Managed Instance
$secpasswd = "PWD27!"+(New-Guid).Guid | ConvertTo-SecureString -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ("azureuser", $secpasswd)

# Set the SQL Managed Instance service tier, compute level, and license mode
$edition = "General Purpose"
$vCores = 4
$maxStorage = 32
$computeGeneration = "Gen5"
$license = "LicenseIncluded" #"BasePrice" or LicenseIncluded if you have don't have SQL Server license that can be used for AHB discount

# Set failover group details
$vpnSharedKey = "mi1mi2psk"
$failoverGroupName = "failovergroup-$randomIdentifier"

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
