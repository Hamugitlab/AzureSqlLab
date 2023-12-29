$scriptUrlBase = 'https://raw.githubusercontent.com/Microsoft/sql-server-samples/master/samples/manage/azure-sql-db-managed-instance/attach-vpn-gateway'

$parameters = @{
    subscriptionId = 'f3158665-b952-4650-aa6e-1e8d23671391'
    environmentName = 'AzureCloud'
    resourceGroupName = 'myResourceGroup-1645193313'
    virtualNetworkName = 'myVnet-486009861'
    certificateNamePrefix  = 'cert4myminame-960471712'
}

Invoke-Command -ScriptBlock ([Scriptblock]::Create((iwr ($scriptUrlBase+'/attachVPNGateway.ps1?t='+ [DateTime]::Now.Ticks)).Content)) -ArgumentList $parameters, $scriptUrlBase