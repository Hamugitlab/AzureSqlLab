# On-demand backups on SQL Managed Instance https://techcommunity.microsoft.com/t5/azure-sql-blog/how-to-take-secure-on-demand-backups-on-sql-managed-instance/ba-p/3638369
# The resources we’ll be working with are:
# One Azure SQL Managed Instance named 
# One Azure Storage account named 
# One container in mystorage01 named 
# User Managed Identify 
# Key Vault with Access Policies policy 

# Identified SMI or UMI 
$MI = get-azsqlinstance -resourcegroupname himresourcegroup -name himsqlservermi
#$MI.Identity.UserAssignedIdentities | ConvertTo-Json
$MI.Identity.principalId




