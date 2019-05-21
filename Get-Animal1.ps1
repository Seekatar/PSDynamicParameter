<#
.SYNOPSIS
Sample function for dynamic parameters
#>
function Get-Animal1 {
[CmdletBinding()]
param ()

DynamicParam
{
    # create a dictionary to return, and collection of parameters
    $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
    $attributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]

    # create a new [string] parameter for all parameter sets, and decorate with a [ValidateSet]
    $dynParam = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("Animal", [String], $attributeCollection)
    $attributes = New-Object System.Management.Automation.ParameterAttribute
    $paramOptions = New-Object System.Management.Automation.ValidateSetAttribute -ArgumentList 'cow','pig','horse'

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