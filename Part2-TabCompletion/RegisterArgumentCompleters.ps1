$script:serverInstance = "localhost"

function script:Get-TableName {
param(
[Parameter(Mandatory)]
[string] $DatabaseName,
[string] $WordToComplete
)
    Invoke-SqlCmdTest -ServerInstance $script:serverInstance -Database $DatabaseName -Query "select name from sys.tables WHERE NAME LIKE '$WordToComplete%' ORDER BY name" |
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
    Invoke-SqlCmdTest -ServerInstance $script:serverInstance -Database $DatabaseName -Query "select COLUMN_NAME NAME from INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = '$TableName' AND COLUMN_NAME LIKE '$WordToComplete%' ORDER BY NAME" |
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

    Write-TabCompletionLog $commandName $parameterName $wordToComplete $commandAst $fakeBoundParameter
    checkServerInstance $fakeBoundParameter

    return Invoke-SqlCmdTest -ServerInstance $script:serverInstance `
            -Database master `
            -Query "select name from sys.databases WHERE NAME LIKE '$WordToComplete%' ORDER BY NAME" |
            Select-Object -ExpandProperty name

}

$script:tableTabComplete = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    Write-TabCompletionLog $commandName $parameterName $wordToComplete $commandAst $fakeBoundParameter
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

    Write-TabCompletionLog $commandName $parameterName $wordToComplete $commandAst $fakeBoundParameter

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

$script:localhostTabComplete = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    Write-TabCompletionLog $commandName $parameterName $wordToComplete $commandAst $fakeBoundParameter

    $progressName = "This is a sample of the long process"
    Write-Progress $progressName
    foreach ($i in 0..10)
    {
        Write-Progress $progressName -PercentComplete ($i*10) -Status "$i"
        Start-Sleep -Milliseconds 100
    }
    Write-Progress $progressName -Completed
    return "localhost","127.0.0.1","::1"
}

$script:nativeCommandTabComplete = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    Write-TabCompletionLog $commandName $parameterName $wordToComplete $commandAst $fakeBoundParameter

    if ($parameterName.CommandElements[-1] -match "^-animal$")
    {
        "chicken","pig","elephant"
    }
}

Register-ArgumentCompleter -CommandName "Get-SQLRow","Get-SQLTable","Get-SQLColumn" `
        -ParameterName "Database" `
        -ScriptBlock $script:databaseTabComplete
Register-ArgumentCompleter -CommandName "Get-SQLRow","Get-SQLColumn" `
        -ParameterName "Table" `
        -ScriptBlock $script:tableTabComplete
Register-ArgumentCompleter -CommandName "Get-SQLRow" `
        -ParameterName "Column" `
        -ScriptBlock $script:columnTabComplete
Register-ArgumentCompleter -CommandName "Get-SQLRow" `
        -ParameterName "OrderBy" `
        -ScriptBlock $script:columnTabComplete
Register-ArgumentCompleter -CommandName "Get-LocalHost" `
        -ParameterName "Name" `
        -ScriptBlock $script:localhostTabComplete
