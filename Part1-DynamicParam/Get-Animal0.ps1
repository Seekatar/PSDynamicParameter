<#
.SYNOPSIS
Sample function for dynamic parameters

.NOTES
This is the static sample used for a starting point
#>
function Get-Animal0
{
[CmdletBinding()]
param(
[ValidateSet('cow','pig','horse')]
[string] $Animal
)
Set-StrictMode -Version Latest
$Animal
}