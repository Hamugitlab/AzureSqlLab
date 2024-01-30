# Show randomized variables
Write-host "Resource group name is" $resourceGroupName
Write-host "Password is" $secpasswd
Write-host "Primary Virtual Network name is" $primaryVNet
Write-host "Primary default subnet name is" $primaryDefaultSubnet
Write-host "Primary managed instance subnet name is" $primaryMiSubnetName
Write-host "Secondary Virtual Network name is" $secondaryVNet
Write-host "Secondary default subnet name is" $secondaryDefaultSubnet
Write-host "Secondary managed instance subnet name is" $secondaryMiSubnetName
Write-host "Primary managed instance name is" $primaryInstance
Write-host "Secondary managed instance name is" $secondaryInstance
Write-host "Failover group name is" $failoverGroupName