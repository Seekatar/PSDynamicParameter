<#
.SYNOPSIS
Test script for Register-ArgumentCompleter blog post to simply get localhost

.PARAMETER Name
Name of localhost, can use tab completion

.OUTPUTS
the name supplied
#>

# register tab completion
. (Join-Path $PSScriptRoot "RegisterArgumentCompleters.ps1")

function Get-Localhost
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $Name
)

Set-StrictMode -Version Latest

$Name

}