# Blog Text only (no images or links) see https://blog.clear-measure.com/2019/05/22/powershell-dynamic-prompts-part-2/
In Part 1 I showed how to use the DynamicParam keyword of PowerShell to add a parameter that had a dynamic set of valid values for tab completion. PowerShell also has a TabCompletion feature that you can hook into to give you more control over how tab completion works. I had used that, but then stumbled upon PowerShell v5’s even better solution, Register-ArgumentCompleter.

This tab completion technique is really useful to list items dynamically, especially when dealing with a hierarchy of metadata. With this post I’ll walk through creating a function that allows the user to get data from SQL Server using tab completion for database, table, and column names.

All of the examples in this post and more are available on GitHub here They have been run on PowerShell v5 and v6 (PowerShell Core) on Windows 10.  At the time of this writing, for Linux I couldn't get the preview of Invoke-SqlCmd working, but the Get-Localhost example doesn't require SQL and works on Linux.
## Register-ArgumentCompleter
This PowerShell cmdlet lets you attach a tab completion scriptblock to a parameter on one or more commands. Here’s how to attach a block to the Database parameter of three functions.

```powershell
Register-ArgumentCompleter -CommandName "Get-SQLRow","Get-SQLTable","Get-SQLColumn" `
-ParameterName "Database" `
-ScriptBlock $script:databaseTabComplete
```

The scriptblock parameter passed to Register-ArgumentCompleter takes the following parameters, most of which will have detail below

* $commandName – name of the command being run, e.g. Get-SQLRow
* $parameterName – name of the parameter being tabbed
* $wordToComplete – if the user has started to type and pressed tab, this will be the text they typed
* $commandAst – the abstract syntax tree for the command. I’ll use this for a specific case
* $fakeBoundParameter – a $PSBoundParameter-like collection of the parameters that have already been entered

The output of the scriptblock will be the values use then for tabbing. The scriptblock is called the first time the user presses tab on a parameter, or types and presses tab. In the example code, I have a switch to dump out all the parameters on each call so you can see what’s going on.

In our most simple case, we just return a static list of strings.

```powershell
$script:serverInstanceTabComplete = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    return "localhost","127.0.0.1","::1"
}
```
The parameters passed into the scriptblock looks like this (output from the example’s logit function), which isn’t too interesting since there’s only one parameter.

```json
// === User pressed tab ===
{
  "commandName": "Get-Localhost",
  "wordToComplete": "",
  "parameterName": "Name",
  "fakeBoundParameter": {}
},
```
To make it more interesting and dynamic, we’ll get a list of tables from a database using tab completion of the database name from the list on SQL Server. Notice in the gif below, I type ‘c’ to tab through names staring with ‘c’, and then ‘n’ to get Northwind.


The parameters passed into the scriptblock after typing ‘n’ and tab are as follows:

```json
// === User pressed tab ===
{
  "wordToComplete": "n",
  "fakeBoundParameter": {
    "Database": "n"
  },
  "commandName": "Get-SQLTable",
  "parameterName": "Database"
}
```
The scriptblock for this command makes a call to SQL Server for the list of databases, and uses the $wordToComplete variable to restrict what it returns.

```powershell
$script:databaseTabComplete = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    logit $commandName $parameterName $wordToComplete $commandAst $fakeBoundParameter
    checkServerInstance $fakeBoundParameter

    return Invoke-SqlCmd -ServerInstance $script:serverInstance `
            -Database master `
            -Query "SELECT name FROM sys.databases WHERE NAME LIKE '$WordToComplete%' ORDER BY NAME" |
            Select-Object -ExpandProperty name

}
```
All of this code is in RegisterArgumentCompleters.ps1 and you may notice that the only link from the tab completion code to the command is the call to Register-ArgumentCompleter, which is very different from the tightly-bound DynamicParam feature from Part 1. The function we’re adding the tab completion to doesn’t know anything about that. Here’s the code for Get-SQLTable, which is just a typical function with nothing special about its parameters.

```powershell
function Get-SQLTable
{
[CmdletBinding()]
param(
[Parameter(Mandatory)]
[string] $Database,
[ValidateNotNullOrEmpty()]
[string] $ServerInstance = "localhost"
)
$query = "Select name from sys.tables order by name"
Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $query
}
```

## Full Example
The function Get-SQLColumn example function simply adds the next level, tables, which you are free to explore, but lets jump to the pinnacle of tab completion, Get-SQLRow It has script blocks registered for four of its parameters! (Mind blown, right?)

```powershell
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
```
The database and table scriptblocks are pretty straightforward, so let’s look at the one to get columns. We want to allow multiple columns, but we don’t want to show ones they’ve already chosen.

```powershell
$script:columnTabComplete = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    if ( $fakeBoundParameter.keys -contains "Database" -and $fakeBoundParameter.keys -contains "Table")
    {
        $excludes = @()

        if ( $commandAst.commandElements[-1].Extent )
        {
            $excludes = $commandAst.commandElements[-1].Extent -split ","
        }

        Invoke-SqlCmd -ServerInstance $script:serverInstance `
                      -Database $DatabaseName `
                      -Query "SELECT COLUMN_NAME NAME
                             FROM INFORMATION_SCHEMA.COLUMNS
                             WHERE TABLE_NAME = '$TableName'
                                AND COLUMN_NAME LIKE '$WordToComplete%'
                                ORDER BY NAME" |
                Select-Object -ExpandProperty name  |
                Where-Object { $_ -notin $excludes }
    }
    else
    {
        return $null
    }
}
```
I make sure I have database and table values already, and then see if there is already something for the columns. I get this from the last command element ($commandAst.commandElements[-1].Extent). When returning the results, the existing values are removed via -notin. The commandAst‘s list of Extents is shown below with the last one being City,Address since that what was already on the parameter.

```"Get-SQLRow"
"-Database"
"Northwind"
"-Table"
"Customers"
"-Column"
"City,Address,"
```
## A Few Tips
The user can use tab completion to help them out, but this is not like ValidateSet that restricts the values. The user can type anything they like as a parameter, and you should validate the parameters in code or with a parameter attribute. For instance for a column name in Get-SQLRow the user can use *. (You could even add that to the list of strings returned to have it be one of the choices.) I’ve used some validation attributes in the examples.

If getting your parameters takes some significant time, you can cache values in a PowerShell module to improve performance. You can use Write-Progress in the scriptblock to provide some feedback, but note that you are blocking the console while your code is running. So if you have you need to do something that takes some time, you should have a separate command to load the cache, and only use tab completion it’s loaded loaded.

As mentioned earlier, the tab completion code is totally separate from the command that it’s adding tab completion to. In fact, you can add your tab completion to anything! In the example code’s RegisterArgumentOtherCompleters.ps1 are scriptblocks to attach to Get-PhysicalDisk, Get-WmiObject, and git Note that for git I use the -Native parameter and have to check in code since PowerShell doesn’t know what git wants, so I’ll fake out an animal parameter.

```powershell
Register-ArgumentCompleter -CommandName "Get-PhysicalDisk" `
             -ParameterName "FriendlyName" `
             -ScriptBlock $script:otherCommandTabComplete
Register-ArgumentCompleter -CommandName "Get-WmiObject"  `
            -ParameterName "Class" `
            -ScriptBlock $script:otherCommandTabComplete
Register-ArgumentCompleter -CommandName "git" `
            -ScriptBlock $script:nativeCommandTabComplete `
            -Native
```
All except the Get-Localhost example require the SqlServer module to be installed. And the examples are just that, and aren’t production code, especially in regards to SQL injections. The commands used in RegisterArgumentOtherCompleters.ps1 are mainly Windows commands.

## Debugging
If you press tab and get nothing, or more typically a filename, either you didn’t register your scriptblock with the correct function and parameter names, or there’s an error getting the values. Using the debugger works pretty well. Writing with the standard Write-* commands will do nothing, or show up as a tab option, as in this case when Write-Warning "Warn" was in the scriptblock shown here.


Writing to a file seems to be the most reliable way to get output out. In the example code’s logit.ps1 there are switches to control dumping out data on each tab press. Since all the scriptblock’s output is used for the set of values, be careful not to accidentally output something, or use Write-Output. Make sure you capture return values from all the functions you call otherwise, they’ll be output.

## Final Thoughts
Like Part 1, I hope this has provided you some useful information about making users’ lives easier. In the past, I used this technique to create a set of functions over an API to query a generic data model. A call was made to cache metadata about the model, then used tab completion for the hierarchy of the object model from namespace, to object, to attributes.

## Links
Sample code for this blog on GitHub
Register-ArgumentCompleter reference documentation
SQLServer for PowerShell module in the Gallery
Blog post about installing the preview version of SQLServer module on PSv6