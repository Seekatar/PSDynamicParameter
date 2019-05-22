$script:debuggingTabCompletion = $true
if ($env:TEMP)
{
    $script:debuggingTabFile = "$env:TEMP\tabcompletion.jsonc"
}
else
{
    # WSL on Linux doesn't have TEMP
    $script:debuggingTabFile = New-TemporaryFile
}

$script:serverInstance = "localhost"
$script:logAst = $true

function script:logit {
param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    if ( $script:debuggingTabCompletion )
    {
        [System.IO.File]::AppendAllText($script:debuggingTabFile, `
            "// === User pressed tab ===`n$(ConvertTo-Json @{commandName=$commandName;parameterName=$parameterName;wordToComplete=$wordToComplete;fakeBoundParameter=$fakeBoundParameter}),`n")
        if ($script:logAst)
        {
            [System.IO.File]::AppendAllText($script:debuggingTabFile, "$(ConvertTo-Json $commandAst -Depth 1)`n") # > 1 breaks tab completion due to error
        }
    }
}

function script:Get-TableName {
param(
[Parameter(Mandatory)]
[string] $DatabaseName,
[string] $WordToComplete
)
    Invoke-SqlCmd -ServerInstance $script:serverInstance -Database $DatabaseName -Query "select name from sys.tables WHERE NAME LIKE '$WordToComplete%' ORDER BY name" |
            Select-Object -ExpandProperty name
}

function script:Get-ColumnName {
param(
[Parameter(Mandatory)]
[string] $DatabaseName,
[Parameter(Mandatory)]
[string] $TableName,
[string] $WordToComplete
)
    Set-StrictMode -Version Latest
    Invoke-SqlCmd -ServerInstance $script:serverInstance -Database $DatabaseName -Query "select COLUMN_NAME NAME from INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '$TableName' AND COLUMN_NAME LIKE '$WordToComplete%' ORDER BY NAME" |
            Select-Object -ExpandProperty name
}

function script:checkServerInstance {
param(
[Parameter(Mandatory)]
$fakeBoundParameter
)
    if ( $fakeBoundParameter.keys -contains "ServerInstance")
    {
        $script:serverInstance = $fakeBoundParameter["ServerInstance"]
    }
    else
    {
        $script:serverInstance = "localhost"
    }
}

$script:databaseTabComplete = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    logit $commandName $parameterName $wordToComplete $commandAst $fakeBoundParameter
    checkServerInstance $fakeBoundParameter

    return Invoke-SqlCmd -ServerInstance $script:serverInstance `
            -Database master `
            -Query "select name from sys.databases WHERE NAME LIKE '$WordToComplete%' ORDER BY NAME" |
            Select-Object -ExpandProperty name

}

$script:tableTabComplete = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    logit $commandName $parameterName $wordToComplete $commandAst $fakeBoundParameter
    checkServerInstance $fakeBoundParameter

    if ( $fakeBoundParameter.keys -contains "Database")
    {
         return Get-TableName $fakeBoundParameter["Database"] $wordToComplete
    }
    else
    {
        return $null
    }
}

$script:columnTabComplete = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    logit $commandName $parameterName $wordToComplete $commandAst $fakeBoundParameter

    checkServerInstance $fakeBoundParameter

    if ( $fakeBoundParameter.keys -contains "Database" -and $fakeBoundParameter.keys -contains "Table")
    {
        $excludes = @()

        if ( $commandAst.commandElements[-1].Extent )
        {
            $excludes = $commandAst.commandElements[-1].Extent -split ","
        }

        return Get-ColumnName $fakeBoundParameter["Database"] $fakeBoundParameter["Table"] $wordToComplete | Where-Object { $_ -notin $excludes }
    }
    else
    {
        return $null
    }
}

$script:serverInstanceTabComplete = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    logit $commandName $parameterName $wordToComplete $commandAst $fakeBoundParameter

    return "localhost","127.0.0.1","::1"
}

Register-ArgumentCompleter -CommandName "Get-SQLRow","Get-SQLTable","Get-SQLColumn" -ParameterName "Database" -ScriptBlock $script:databaseTabComplete
Register-ArgumentCompleter -CommandName "Get-SQLRow","Get-SQLColumn" -ParameterName "Table" -ScriptBlock $script:tableTabComplete
Register-ArgumentCompleter -CommandName "Get-SQLRow" -ParameterName "Column" -ScriptBlock $script:columnTabComplete
Register-ArgumentCompleter -CommandName "Get-SQLServerInstance" -ParameterName "ServerInstance" -ScriptBlock $script:serverInstanceTabComplete

function Get-TabCompletionLogFile
{
[CmdletBinding()]
param()
Set-StrictMode -Version Latest

return $script:debuggingTabFile

}