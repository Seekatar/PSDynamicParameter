<#
.SYNOPSIS
Sample function for dynamic parameters, this is Get-Animal2 using New-ValidateSetParameter

.PARAMETER wild
If set animals are wild!
#>
function Get-Animal4 {
param (
[Parameter()]
[switch] $wild
)


DynamicParam
{
    . (Join-Path $PSScriptRoot "New-ValidateSetParameter.ps1")

    return New-ValidateSetParameter -ParameterName "Animal" -ValidateSetScript {
        $fname = "animals.json"
        if ( (Test-Path variable:wild) -and $wild )
        {
            $fname = "wildanimals.json"
        }
        return (ConvertFrom-Json (Get-Content (join-path $PSScriptRoot $fname) -Raw))
    }
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