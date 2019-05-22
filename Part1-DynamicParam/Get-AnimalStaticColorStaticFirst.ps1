<#
.SYNOPSIS
Sample function for dynamic parameters

.NOTES
This has the static parameter first when no parameter name is used, regardless of the Position parameters indicating otherwise
#>
function Get-AnimalStaticColorStaticFirst {
[CmdletBinding(PositionalBinding)]
param(
[Parameter(Position=1)]
[ValidateSet('red','blue','green')]
[string] $Color
)

DynamicParam
{
    . (Join-Path $PSScriptRoot "New-ValidateSetParameter.ps1")
    return New-ValidateSetParameter -ParameterName "Animal" -ValidateSet 'cow','pig','horse' -Position 0
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
