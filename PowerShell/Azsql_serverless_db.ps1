

# Set variables for your server and database
$resourceGroupName = "myResourceGroupHim"
$location = "eastus"
$adminLogin = "azureuser"
$password = "Azure1234567!"
$serverName = "mysqlserver-$(Get-Random)"
$databaseName = "mySampleDatabaseHim"

# The ip address range that you want to allow to access your server
$startIp = "0.0.0.0"
$endIp = "0.0.0.0"

# Show randomized variables
Write-host "Resource group name is" $resourceGroupName
Write-host "Server name is" $serverName

Write-host "Creating resource group..."
$resourceGroup = New-AzResourceGroup -Name $resourceGroupName -Location $location -Tag @{Owner="SQLDB-Samples"}
$resourceGroup


Write-host "Creating primary server..."
$server = New-AzSqlServer -ResourceGroupName $resourceGroupName `
   -ServerName $serverName `
   -Location $location `
   -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential `
   -ArgumentList $adminLogin, $(ConvertTo-SecureString -String $password -AsPlainText -Force))
$server

Write-host "Configuring server firewall rule..."
$serverFirewallRule = New-AzSqlServerFirewallRule -ResourceGroupName $resourceGroupName `
   -ServerName $serverName `
   -FirewallRuleName "AllowedIPs" -StartIpAddress $startIp -EndIpAddress $endIp
$serverFirewallRule

Write-host "Creating a gen5 2 vCore serverless database..."
$database = New-AzSqlDatabase  -ResourceGroupName $resourceGroupName `
   -ServerName $serverName `
   -DatabaseName $databaseName `
   -Edition GeneralPurpose `
   -ComputeModel Serverless `
   -ComputeGeneration Gen5 `
   -VCore 2 `
   -MinimumCapacity 2 `
   -SampleName "AdventureWorksLT"
$database