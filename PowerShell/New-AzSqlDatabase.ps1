# Install-Module -Name AzureRM -AllowClobber

$subscriptionId = "f3158665-b952-4650-aa6e-1e8d23671391"
$location = "eastus"
$resourceGroup = "my-resource-group"

$managedInstance = "myResourceGroup-1645193313"
$database = "my-db"

Select-AzureRmSubscription -SubscriptionId $subscriptionId 

New-AzureRmResource -Location $location -ResourceId "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.Sql/managedInstances/$managedInstance/databases/$database" -ApiVersion "2017-03-01-preview" -AsJob -Force