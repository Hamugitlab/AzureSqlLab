# Description

The `SqlDatabaseRole` DSC resource is used to create a database role when
Ensure is set to 'Present' or remove a database role when Ensure is set to
'Absent'. The resource also manages members in both built-in and user
created database roles. If the targeted database is not updatable, the resource
returns true.

## Requirements

* Target machine must be running Windows Server 2012 or later.
* Target machine must be running SQL Server Database Engine 2012 or later.

## Known issues

All issues are not listed here, see [here for all open issues](https://github.com/dsccommunity/SqlServerDsc/issues?q=is%3Aissue+is%3Aopen+in%3Atitle+SqlDatabaseRole).
