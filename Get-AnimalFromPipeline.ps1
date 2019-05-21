<#
.SYNOPSIS
Sample function for dynamic parameters

.EXAMPLE
"pig","horse" | Get-AnimalFromPipeline
#>
function Get-AnimalFromPipeline {
[CmdletBinding()]
param()

DynamicParam
{
    . (Join-Path $PSScriptRoot "New-ValidateSetParameter.ps1")
    return New-ValidateSetParameter -ParameterName "Animal" -ValidateSet 'cow','pig','horse' `
                        -Mandatory -ValueFromPipeline
}

Process
{
    Set-StrictMode -Version Latest
    # no key check since mandatory
    $PSBoundParameters.Animal
}
}
