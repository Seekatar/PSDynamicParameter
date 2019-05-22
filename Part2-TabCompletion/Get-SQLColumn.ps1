<#
.SYNOPSIS
Test script for Register-ArgumentCompleter blog post

.PARAMETER Database
Database name, can use tab completion

.PARAMETER Table
Table name, can use tab completion

.PARAMETER ServerInstance
Server/instance to run the queries on

.EXAMPLE
An example

.NOTES
WARNING: This is just a sample and only makes a modest attempt at prevent SQL injection.
#>

# register tab completion
. (Join-Path $PSScriptRoot "RegisterArgumentCompleters.ps1")

function Get-SQLColumn
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $Database,
[Parameter(Mandatory)]
[string] $Table,
[ValidateNotNullOrEmpty()]
[string] $ServerInstance = "localhost"
)

Set-StrictMode -Version Latest

$query = "select COLUMN_NAME NAME from INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '$TableName' ORDER BY NAME"

if ($query -match "[';]")
{
    throw "Possible SQL injection in '$query'"
}
Write-Verbose "Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query `"$query`""

Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $query

}