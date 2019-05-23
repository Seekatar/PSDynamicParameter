# PowerShell Dynamic Parameter Values
This repo contains the example code for the PowerShell Dynamic Parameter blog posts.  All of these run on PowerShell v5 on Windows and PowerShell v6 (Core) on Windows and Linux.

In [Part 1](https://blog.clear-measure.com/2019/05/21/powershell-dynamic-prompts-part-1/) I show how to use the `DynamicParam` keyword of PowerShell.

In [Part 2](https://blog.clear-measure.com/2019/05/22/powershell-dynamic-prompts-part-2/) I show how to use `Register-ArgumentCompleter` to add tab completion values to your own or anyone else's commands.

# Using /Part1-DynamicParam Example Code
This folder contains the progression of a `Get-Animal` function discussed [Part 1](https://blog.clear-measure.com/2019/05/21/powershell-dynamic-prompts-part-1/).  It uses a dynamic `[ValidateSet]` to allow tab completion, and restriction of values on-the-fly.

`Import-Module .\Get-Animals.psm1` will import all the examples for you to run, or you can dot-source any file.

`Invoke-Pester` will run test to test the valid values for the sets.

# Using /Part2-TabCompletion Example Code
This folder has example code to do dynamic tab completion for a set of functions that use metadata from SQL Server, as discussed in [Part 2](https://blog.clear-measure.com/2019/05/22/powershell-dynamic-prompts-part-2/).  These depend on the PowerShell [SQLServer module](https://www.powershellgallery.com/packages/SqlServer/21.1.18095-preview) and the Pester tests require the [Northwind](https://docs.microsoft.com/en-us/dotnet/framework/data/adonet/sql/linq/downloading-sample-databases) database

`Import-Module .\RegisterArgumentCompleter.psm1` will import all the SQL Server examples.  `Invoke-Pester` will run some tests to make sure SQL Server returns values from the Northwind database

On WSL (Windows Subsystem for Linux) or non-Windows, make sure [TCP is enabled](https://docs.microsoft.com/en-us/sql/database-engine/configure-windows/enable-or-disable-a-server-network-protocol?view=sql-server-2017#PowerShellProcedure) for SQL Server.  In those cases you'll probably also have to call `Set-SQLCredential` to set the credentials for the tab completion. Running on WSL using a local SQL Server I used these commands

```powershell
ipmo ./RegisterArgumentCompleter.psm1
Set-SQLCredential -Username sa -Password .....
Invoke-Pester
```

Localhost is the default server/instance for all queries, but you can override with a `-ServerInstance` parameter.
```powershell
Get-SQLTable -ServerInstance .\sqlexpress
```

`. .\RegisterOtherArgumentCompleters.ps1` will register tab completion on built in commands: a function (`Get-InstalledModule`), cmdlet (`Get-Host`), and native command (`git.exe`).  This works on Windows and Linux.


