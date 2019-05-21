
function Get-Something
{
[CmdletBinding()]
param(
[ValidateSet('red','blue','green')]
[string] $Color
)

Set-StrictMode -Version Latest

}