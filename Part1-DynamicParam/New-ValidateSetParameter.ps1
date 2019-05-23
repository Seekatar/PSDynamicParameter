<#
.SYNOPSIS
Helper for making dynamic parameters with ValidateSet attribute

.PARAMETER ParameterName
Name of dynamic parameter

.PARAMETER ValidateSetScript
A scriptblock to create the ValidateSet list

.PARAMETER Alias
Alias for parameter

.PARAMETER ParameterSetName
Parameter set name

.PARAMETER Mandatory
If the parameter is mandatory

.PARAMETER ValueFromPipeline
If the parameter is from the pipeline

.PARAMETER Position
Position to set

.PARAMETER Help
Optional help

.PARAMETER DebugFile
File for outputing debug information, for debugging dyn parameters

.EXAMPLE
function Get-Animal {
[CmdletBinding()]
param ()


DynamicParam
{
    . (Join-Path $PSScriptRoot "New-ValidateSetParameter.ps1")
    return New-ValidateSetParameter -ParameterName "animal" -ValidateSet 'cow','pig','horse'
}

Process
{
	Set-StrictMode -Version Latest
	if ( $PSBoundParameters.Keys.Contains("animal") )
	{
        "You chose $($PSBoundParameters.animal)"
	}
}
}

.EXAMPLE
function Get-Animal {
param (
[Parameter()]
[switch] $wild
)


DynamicParam
{
    . (Join-Path $PSScriptRoot "New-ValidateSetParameter.ps1")

    return New-ValidateSetParameter -ParameterName "animal" -ValidateSetScript {
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
	if ( $PSBoundParameters.Keys.Contains("animal") )
	{
        "You chose $($PSBoundParameters.animal)"
	}
}
}

.EXAMPLE
function Get-AnimalAndColor {
[CmdletBinding()]
param(
)

DynamicParam
{
    . (Join-Path $PSScriptRoot "New-ValidateSetParameter.ps1")
    return New-ValidateSetParameter -ParameterName "animal" -ValidateSet 'cow','pig','horse' |
           New-ValidateSetParameter -ParameterName "color" -ValidateSet 'red','blue','green' |
}

Process
{
	Set-StrictMode -Version Latest
	if ( $PSBoundParameters.Keys.Contains("animal") )
	{
        "You chose $($PSBoundParameters.animal)"
	}
}
}
#>
function New-ValidateSetParameter
{
[CmdletBinding()]
param(
[Parameter(Mandatory,ParameterSetName="ValidateScriptBlock",Position=1)]
[Parameter(Mandatory,ParameterSetName="ValidateSet",Position=1)]
[string] $ParameterName,
[Parameter(Mandatory,ParameterSetName="ValidateScriptBlock")]
[scriptblock] $ValidateSetScript,
[Parameter(Mandatory,ParameterSetName="ValidateSet")]
[string[]] $ValidateSet,
[string] $Alias,
[string] $ParameterSetName,
[switch] $Mandatory,
[switch] $ValueFromPipeline,
[switch] $ValueFromPipelineByPropertyName,
[int] $Position = 0,
[string] $Help,
[string] $DebugFile,
[Parameter(ValueFromPipeline)]
[System.Management.Automation.RuntimeDefinedParameterDictionary] $ParamDictionary
)
    Set-StrictMode -Version Latest
    function Write-ValidateSetLog($msg) {
        if ( $DebugFile ) { "$(Get-Date -form 's') $msg" | out-file $DebugFile -Append -Encoding utf8 }
    }

    Write-ValidateSetLog "makeDynamicParam for $ParameterName"

    # create a dictionary to return,
    if ( !$ParamDictionary )
    {
        $ParamDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
    }

    # create a new [string] dyn parameter with a collection of attributes
    $attributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]
    $dynParam = New-Object -Type System.Management.Automation.RuntimeDefinedParameter($ParameterName, [String], $attributeCollection)
    $attributes = New-Object System.Management.Automation.ParameterAttribute

    if ( $ParameterSetName )
    {
        $attributes.ParameterSetName = $ParameterSetName
    }
    if ( $Help )
    {
        $attributes.HelpMessage = $Help
    }
    $attributes.Mandatory = [bool]$Mandatory
    $attributes.ValueFromPipeline = [bool]$ValueFromPipeline
    $attributes.ValueFromPipelineByPropertyName = [bool]$ValueFromPipelineByPropertyName
    $attributes.Position = $Position
    Write-ValidateSetLog "Attributes are $(ConvertTo-Json ($attributes | Select-Object * -ExcludeProperty "TypeId")  -Depth 1)"

    if ( $ValidateSetScript )
    {
        try
        {
            Write-ValidateSetLog "About to invoke script passed in"
            $ValidateSet = $ValidateSetScript.Invoke()
        }
        catch {
            Write-ValidateSetLog "Exception from ValidateSetScript: $_"
        }
    }
    Write-ValidateSetLog "list is now $($ValidateSet | out-string)"
    if ( $ValidateSet )
    {
        $paramOptions = New-Object System.Management.Automation.ValidateSetAttribute -ArgumentList $ValidateSet
        $attributeCollection.Add($paramOptions)
    }

    # hook things together
    $attributeCollection.Add($attributes)
    $ParamDictionary.Add($ParameterName, $dynParam)

    return $ParamDictionary
}
