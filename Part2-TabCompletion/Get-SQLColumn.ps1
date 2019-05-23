<#
.SYNOPSIS
Test script for Register-ArgumentCompleter blog post to get the column names for a table

.PARAMETER Database
Database name, can use tab completion

.PARAMETER Table
Table name, can use tab completion

.PARAMETER ServerInstance
Server/instance to run the queries on, defaults to localhost

.EXAMPLE
Get-SQLColumn -Database Northwind -Table Customers

.NOTES
WARNING: This is just a sample and only makes a modest attempt at prevent SQL injection.
#>

# register tab completion
. (Join-Path $PSScriptRoot "RegisterArgumentCompleters.ps1")

function Get-SQLColumn
{
[CmdletBinding()]
param(
[ValidatePattern('^[\w\d_@#]+$')]
[Parameter(Mandatory)]
[string] $Database,
[ValidatePattern('^[\w\d_@#]+$')]
[Parameter(Mandatory)]
[string] $Table,
[ValidateNotNullOrEmpty()]
[string] $ServerInstance = "localhost"
)

Set-StrictMode -Version Latest

if ($Table -match "[';]")
{
    throw "Possible SQL injection in '$query'"
}

$query = "select COLUMN_NAME NAME from INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '$Table' ORDER BY NAME"

Invoke-SqlcmdTest $ServerInstance $Database $query

}