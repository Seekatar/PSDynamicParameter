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
$script:logAst = $true

<#
.SYNOPSIS
Helper function used to log parameters for tab completion scriptblock
#>

function Write-TabCompletionLog {
param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    if ( $script:debuggingTabCompletion )
    {
        [System.IO.File]::AppendAllText($script:debuggingTabFile, `
            "// === User pressed tab ===`n$(ConvertTo-Json @{commandName=$commandName;parameterName=$parameterName;wordToComplete=$wordToComplete;fakeBoundParameter=$fakeBoundParameter}),`n")
        if ($script:logAst -and $commandAst)
        {
            [System.IO.File]::AppendAllText($script:debuggingTabFile, "$(ConvertTo-Json $commandAst -Depth 1),`n") # > 1 breaks tab completion due to error
            if ($commandAst.CommandElements -and $commandAst.CommandElements)
            {
                [System.IO.File]::AppendAllText($script:debuggingTabFile, "`"Extents`":`n[`n")
                foreach( $c in $commandAst.CommandElements)
                {
                    if (Get-Member -InputObject $c -Name Extent)
                    {
                        [System.IO.File]::AppendAllText($script:debuggingTabFile,   "$(ConvertTo-Json $c.Extent.toString() -Depth 1)`n")
                    }
                }
                [System.IO.File]::AppendAllText($script:debuggingTabFile, "]`n")
            }
        }
    }
}


<#
.SYNOPSIS
Get the log file name used if logging is on.

.DESCRIPTION
For Windows this will be "$env:TEMP\tabcompletion.jsonc", otherwise New-TemporaryFile was used

.OUTPUTS
The filename
#>
function Get-TabCompletionLogFile
{
[CmdletBinding()]
param()
Set-StrictMode -Version Latest

return $script:debuggingTabFile

}