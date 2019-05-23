$script:username = ""
$script:password = ""

<#
.SYNOPSIS
Helper for keeping things DRY, not exported
#>

function Invoke-SqlcmdTest
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $ServerInstance,
[Parameter(Mandatory)]
[string] $Database,
[Parameter(Mandatory)]
[string] $Query
)
Set-StrictMode -Version Latest

Write-Verbose "Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query `"$query`""

$credParams = @{}
if ($script:username -and $script:password)
{
    $credParams["Username"] = $script:username
    $credParams["Password"] = $script:password
}

Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $query @credParams

}

<#
.SYNOPSIS
Set the user/password to pass to Invoke-Sqlcmd

.DESCRIPTION
Invoke-Sqlcmd doesn't take a credential, so the pw is in the clear

.PARAMETER Username
SQL Username

.PARAMETER Password
SQL Password
#>

function Set-SQLCredential
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $Username,
[Parameter(Mandatory)]
[string] $Password
)
Set-StrictMode -Version Latest

$script:username = $Username
$script:password = $Password

}