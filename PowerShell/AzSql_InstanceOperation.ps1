$managedInstance = "himinname"
$resourceGroup = "HimResourceGroup"

Get-AzSqlInstanceOperation  -ManagedInstanceName $managedInstance  -ResourceGroupName $resourceGroup
