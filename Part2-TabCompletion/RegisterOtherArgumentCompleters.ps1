. (Join-Path $PSScriptRoot "Write-TabCompletionLog.ps1")

$script:otherCommandTabComplete = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    Write-TabCompletionLog $commandName $parameterName $wordToComplete $commandAst $fakeBoundParameter

    "chicken","pig","elephant"
}

$script:nativeCommandTabComplete = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    Write-TabCompletionLog $commandName $parameterName $wordToComplete $commandAst $fakeBoundParameter

    # only react to -animals on git.exe
    if ($parameterName.CommandElements[-1] -match "^-animal$")
    {
        "chicken","pig","elephant"
    }
}

# These show how to add tab completion to someone else's function or cmdlet, or exe!
Register-ArgumentCompleter -CommandName "Get-InstalledModule" `
             -ParameterName "Name" `
             -ScriptBlock $script:otherCommandTabComplete
Register-ArgumentCompleter -CommandName "Get-Job"  `
            -ParameterName "InstanceId" `
            -ScriptBlock $script:otherCommandTabComplete
Register-ArgumentCompleter -CommandName "git" `
            -ScriptBlock $script:nativeCommandTabComplete `
            -Native
