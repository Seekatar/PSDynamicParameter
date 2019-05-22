<#
.SYNOPSIS
Test script for Register-ArgumentCompleter blog post

.PARAMETER ServerInstance
Server/instance to run the queries on, can use tab completion to get localhost values
#>

# register tab completion
. (Join-Path $PSScriptRoot "RegisterArgumentCompleters.ps1")

function Get-SQLServerInstance
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $ServerInstance
)

Set-StrictMode -Version Latest

$ServerInstance

}