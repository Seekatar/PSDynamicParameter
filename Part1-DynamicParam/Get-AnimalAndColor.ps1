<#
.SYNOPSIS
Sample function for dynamic parameters
#>
function Get-AnimalAndColor {
[CmdletBinding()]
param()

DynamicParam
{
    . (Join-Path $PSScriptRoot "New-ValidateSetParameter.ps1")
    return New-ValidateSetParameter -ParameterName "Animal" -ValidateSet 'cow','pig','horse' -Mandatory -Position 0 |
           New-ValidateSetParameter -ParameterName "Color" -ValidateSet 'red','blue','green' -Mandatory -Position 1
}

Process
{
    Set-StrictMode -Version Latest
    # no key check since mandatory
    $($PSBoundParameters.Animal)
    $($PSBoundParameters.Color)
}
}
