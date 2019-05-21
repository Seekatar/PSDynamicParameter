<#
.SYNOPSIS
Sample function for dynamic parameters, this is Get-Animal1 using New-ValidateSetParameter
#>
function Get-Animal3 {
[CmdletBinding()]
param ()


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