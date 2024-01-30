# Create global virtual network peering 
Write-host "Peering primary VNet to secondary VNet. ${env:PRIMARYVNET}.."
$resourceGroupName = ${env:RESOURCEGROUPNAME}
$primaryVNet = ${env:PRIMARYVNET}
$secondaryVNet = ${env:SECONDARYVNET}
$primaryVirtualNetwork  = Get-AzVirtualNetwork `
                  -Name $primaryVNet `
                  -ResourceGroupName $resourceGroupName

$secondaryVirtualNetwork = Get-AzVirtualNetwork `
                  -Name $secondaryVNet `
                  -ResourceGroupName $resourceGroupName
                  
Write-host "Peering primary VNet to secondary VNet..."
Add-AzVirtualNetworkPeering `
 -Name primaryVnet-secondaryVNet1 `
 -VirtualNetwork $primaryVirtualNetwork `
 -RemoteVirtualNetworkId $secondaryVirtualNetwork.Id
 Write-host "Primary VNet peered to secondary VNet successfully."

Write-host "Peering secondary VNet to primary VNet..."
Add-AzVirtualNetworkPeering `
 -Name secondaryVNet-primaryVNet `
 -VirtualNetwork $secondaryVirtualNetwork `
 -RemoteVirtualNetworkId $primaryVirtualNetwork.Id
Write-host "Secondary VNet peered to primary VNet successfully."

Write-host "Checking peering state on the primary virtual network..."
Get-AzVirtualNetworkPeering `
-ResourceGroupName $resourceGroupName `
-VirtualNetworkName $primaryVNet `
| Select PeeringState

Write-host "Checking peering state on the secondary virtual network..."
Get-AzVirtualNetworkPeering `
-ResourceGroupName $resourceGroupName `
-VirtualNetworkName $secondaryVNet `
| Select PeeringState