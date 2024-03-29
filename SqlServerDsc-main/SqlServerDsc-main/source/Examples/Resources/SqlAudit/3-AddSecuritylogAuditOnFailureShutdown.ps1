<#
    .EXAMPLE
        This example shows how to ensure that the windows security event log
        audit destination is present on the instance sqltest.company.local\DSC.
        The server should shutdown when logging is not possible.
#>
Configuration Example
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SqlAdministratorCredential
    )

    Import-DscResource -ModuleName SqlServerDsc

    node localhost
    {
        SqlAudit SecurityLogAudit_Server
        {
            Ensure       = 'Present'
            ServerName   = 'sqltest.company.local'
            InstanceName = 'DSC'
            Name         = 'SecLogAudit'
            OnFailure    = 'Shutdown'
            Enabled      = $true
            Credential   = $SqlAdministratorCredential
        }
    }
}
