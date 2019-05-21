<#
.SYNOPSIS
Sample function for dynamic parameters

.NOTES
This allows the dynamic parameter to be first by default (no parameter name), but still have to supply name for second
#>

function Get-AnimalStaticColorDynamicFirst {
[CmdletBinding(PositionalBinding=$false)]
param(
[Parameter()]
[ValidateSet('red','blue','green')]
[string] $Color
)

DynamicParam
{
    . (Join-Path $PSScriptRoot "New-ValidateSetParameter.ps1")
    return New-ValidateSetParameter -ParameterName "Animal" -ValidateSet 'cow','pig','horse'
}

Process
{
    if ( $PSBoundParameters.Keys.Contains("Animal") )
    {
        $PSBoundParameters.Animal
    }
    $Color
}

}

