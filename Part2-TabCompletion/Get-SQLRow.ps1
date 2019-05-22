<#
.SYNOPSIS
Test script for Register-ArgumentCompleter blog post

.PARAMETER Database
Database name, can use tab completion

.PARAMETER Table
Table name, can use tab completion

.PARAMETER Column
Comma-separated column names, can use tab completion

.PARAMETER OrderBy
Comma-separated column names, can use tab completion

.PARAMETER Descending
If OrderBy is used can change order

.PARAMETER Top
Number of rows to return, defaults to 10

.PARAMETER ServerInstance
Server/instance to run the queries on

.EXAMPLE
An example

.NOTES
WARNING: This is just a sample and only makes a modest attempt at prevent SQL injection.
#>

# register tab completion
. (Join-Path $PSScriptRoot "RegisterArgumentCompleters.ps1")

function Get-SQLRow
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $Database,
[Parameter(Mandatory)]
[string] $Table,
[string[]] $Column,
[string[]] $OrderBy,
[switch] $Descending,
[ValidateRange(1,100000)]
[int] $Top = 10,
[ValidateNotNullOrEmpty()]
[string] $ServerInstance = "localhost"
)

Set-StrictMode -Version Latest

$query = "Select TOP $Top $($Column -join ',') from $table"
if ($query -match "[';]")
{
    throw "Possible SQL injection in '$query'"
}
Write-Verbose "Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query `"$query`""

Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $query

}