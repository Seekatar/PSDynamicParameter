<#
.SYNOPSIS
Function for testing without [CmdletBinding] or [Parameter], causing DynamicParam to not run
#>
function Get-AnimalNoBinding {
param (
[switch] $Wild
)

DynamicParam
{
    . (Join-Path $PSScriptRoot "New-ValidateSetParameter.ps1")
    return New-ValidateSetParameter -ParameterName "Animal" -ValidateSet 'cow','pig','horse'
}

Process
{
    Set-StrictMode -Version Latest
    if ( $PSBoundParameters.Keys.Contains("Animal") )
    {
        $PSBoundParameters.Animal
    }
}
}