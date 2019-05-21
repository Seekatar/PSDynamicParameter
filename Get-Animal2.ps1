<#
.SYNOPSIS
Sample function for dynamic parameters

.PARAMETER wild
If set animals are wild!
#>
function Get-Animal2 {
[CmdletBinding()]
param (
[switch] $wild
)

DynamicParam
{
    # create a dictionary to return, and collection of parameters
    $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
    $attributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]

    # create a new [string] parameter for all parameter sets, and decorate with a [ValidateSet]
    $dynParam = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("Animal", [String], $attributeCollection)
    $attributes = New-Object System.Management.Automation.ParameterAttribute
    $fname = "animals.json"
    if ( (Test-Path variable:wild) -and $wild )
    {
        $fname = "wildanimals.json"
    }
    $paramOptions = New-Object System.Management.Automation.ValidateSetAttribute -ArgumentList (ConvertFrom-Json (Get-Content (join-path $PSScriptRoot $fname) -Raw))

    # hook things together
    $attributeCollection.Add($attributes)
    $attributeCollection.Add($paramOptions)
    $paramDictionary.Add("Animal", $dynParam)

    return $paramDictionary
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