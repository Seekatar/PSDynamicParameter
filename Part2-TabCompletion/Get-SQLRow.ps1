<#
.SYNOPSIS
Test script for Register-ArgumentCompleter blog post to get rows from a SQL Server database

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
Server/instance to run the queries on, defaults to localhost

.EXAMPLE
Get-SQLRow -Database Northwind -Table Customers -Column * | ft

.EXAMPLE
Get-SQLRow -Database Northwind -Table Customers -Column CustomerID,CompanyName -OrderBy CompanyName

.NOTES
WARNING: This is just a sample and only makes a modest attempt at prevent SQL injection.
#>
function Get-SQLRow
{
[CmdletBinding()]
param(
[ValidatePattern('^[\w\d_@#]+$')]
[Parameter(Mandatory)]
[string] $Database,
[ValidatePattern('^[\w\d_@#]+$')]
[Parameter(Mandatory)]
[string] $Table,
[ValidatePattern('^[\w\d_@#,*]+$')]
[string[]] $Column,
[ValidatePattern('^[\w\d_@#,*]+$')]
[string[]] $OrderBy,
[switch] $Descending,
[ValidateRange(1,100000)]
[int] $Top = 10,
[ValidateNotNullOrEmpty()]
[string] $ServerInstance = "localhost"
)

Set-StrictMode -Version Latest

$query = "SELECT TOP $Top $($Column -join ',') FROM $table"
if ($OrderBy)
{
    $query += " ORDER BY $($OrderBy -join ',')"
    if ($Descending)
    {
        $query += " DESC"
    }
}

if ($query -match "[';]")
{
    throw "Possible SQL injection in '$query'"
}

Invoke-SqlcmdTest $ServerInstance $Database $query

}