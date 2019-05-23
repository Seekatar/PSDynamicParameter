<#
.SYNOPSIS
Test script for Register-ArgumentCompleter blog post to get table names

.PARAMETER Database
Database name, can use tab completion

.PARAMETER ServerInstance
Server/instance to run the queries on, defaults to localhost

.EXAMPLE
Get-SQLTable -Database Northwind
#>

# register tab completion
. (Join-Path $PSScriptRoot "RegisterArgumentCompleters.ps1")

function Get-SQLTable
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[ValidatePattern('^[\w\d_@#]+$')]
[string] $Database,
[ValidateNotNullOrEmpty()]
[string] $ServerInstance = "localhost"
)

Set-StrictMode -Version Latest

$query = "Select name from sys.tables order by name"

Invoke-SqlcmdTest $ServerInstance $Database $query

}