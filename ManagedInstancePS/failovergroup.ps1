# Create failover group
$resourceGroupName = ${env:RESOURCEGROUPNAME}
$primaryVNet = ${env:PRIMARYVNET}
$secondaryVNet = ${env:SECONDARYVNET}
$failoverGroupName = ${env:FAILOVERGROUPNAME}
$primaryInstance = ${env:PRIMARYINSTANCE}
$secondaryInstance = ${env:SECONDARYINSTANCE}
$drLocation = ${env:DRLOCATION}
$location = ${env:LOCATION}
./ManagedInstancePS/variablemap.ps1

Write-host "Creating the failover group..."
$failoverGroup = New-AzSqlDatabaseInstanceFailoverGroup -Name $failoverGroupName `
     -Location $location -ResourceGroupName $resourceGroupName -PrimaryManagedInstanceName $primaryInstance `
     -PartnerRegion $drLocation -PartnerManagedInstanceName $secondaryInstance `
     -FailoverPolicy Manual -GracePeriodWithDataLossHours 1
$failoverGroup