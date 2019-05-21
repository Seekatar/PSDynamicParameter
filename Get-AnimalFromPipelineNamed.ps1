<#
.SYNOPSIS
Sample function for dynamic parameters

.EXAMPLE
$animals = [PSCustomObject]@{Animal="cow"},[PSCustomObject]@{Color="red";Animal="pig"}
$animals | Get-AnimalFromPipelineNamed
#>
function Get-AnimalFromPipelineNamed {
[CmdletBinding()]
param()

DynamicParam
{
    . (Join-Path $PSScriptRoot "New-ValidateSetParameter.ps1")
    return New-ValidateSetParameter -ParameterName "Animal" -ValidateSet 'cow','pig','horse' `
                    -Mandatory -ValueFromPipelineByPropertyName |
            New-ValidateSetParameter -ParameterName "Color" -ValidateSet 'red','blue','green' `
                     -ValueFromPipelineByPropertyName
}

Process
{
    Set-StrictMode -Version Latest
    $PSBoundParameters.Animal
    # no key check for Animal since mandatory
    $Color = $null
    if ($PSBoundParameters.Keys.Contains('Color'))
    {
        $Color = $($PSBoundParameters.Color)
    }
    $Color
}
}

