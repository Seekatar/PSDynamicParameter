# Blog Text only (no images or links) see
Second to having objects in the pipeline, one of the best features of PowerShell is tab-completion. Having the ability to discover or guess the names of commands and their parameters greatly increases the productivity of the user, especially when initially using PowerShell.

In this short series of blog posts, I will show how to use tab-completion for your own functions, and how to create dynamic parameters that change the values for tab completion at runtime.

All the source in this post is available on GitHub here and all of the examples have been run on PowerShell v5 on Windows 10 and PowerShell v6 (PowerShell Core) on Windows 10 and Linux.
Note that as the documentation states, dynamic parameters are a bit harder to discover since Get-Help doesn’t show them, so they are a bit of a double-edged sword. You can still discover them with dash then tabbing through parameters. By using dynamic parameters you can get behavior like the tab completion of commands, such as Get-ChildItem (aka dir or ls) for files, or Stop-Service for services.

Some of the recent cases when I’ve used dynamic parameters are for functions like these:

Get-ConfigData that allows tab completion of names previously stored in a config file
Wrapping a psake file to provide tab completion for tab names
API wrapper that provided dynamic lists of commands and parameters based on data from a REST call.
For this first post, I’ll show the simplest way to add dynamic parameters. It will be similar to the static [ValidateSet] attribute that you can put on a parameter (actually, it will be more than similar). Here’s our base sample using a static list of valid values.

```powershell
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
```
Has there been a time where you’ve said, “Boy, I sure wish I could create the list of animals on-the-fly.” Enter the DynamicParam keyword.

## DynamicParam
This keyword is used similar to the begin, process and end keywords of a function. You use this block to add one or more parameters on-the-fly and set attributes of those parameters, such as ValidateSet. To start with a simple example, this will change the static Animal parameter from above to a dynamic parameter.

```powershell
function Get-Animal1 {
[CmdletBinding()]
param ()

DynamicParam
{
    # create a dictionary to return, and collection of parameters
    $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
    $attributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]

    # create a new [string] parameter for all parameter sets, and decorate with a [ValidateSet]
    $dynParam = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("Animal", [String], $attributeCollection)
    $attributes = New-Object System.Management.Automation.ParameterAttribute
    $paramOptions = New-Object System.Management.Automation.ValidateSetAttribute -ArgumentList 'cow','pig','horse'

    # hook things together
    $attributeCollection.Add($attributes)
    $attributeCollection.Add($paramOptions)
    $paramDictionary.Add("Animal", $dynParam)

    return $paramDictionary
}

Process
{
    Set-StrictMode -Version Latest
    if ( $PSBoundParameters.Keys.Contains("Animal") )
    {
        $PSBoundParameters.Animal
    }
}
}
```
Running this command, you’ll be able to do -<tab> to see -Animal as a parameter, then tab through the list of animals, just as with the static example


For PSv6 on Linux, tab completion in general behave a bit differently.


To use the value of the dynamic parameter in your Process block, use the $PSBoundParameters dictionary to check if it exists (if you don’t mark it as Mandatory), and then get the value.

You’ll notice I’m using .NET classes from the System.Management.Automation namespace to create the parameter, set its attributes and hook it into the RuntimeDefinedParameterDictionary that the block returns. The middle part of the code is quite analogous to adding a static parameter. The new RuntimeDefinedParameter is like [string] $Animal The new ValidateSetAttribute is like [ValidateSet( 'cow','pig','horse')] Now this example doesn’t get you any more than the static version, but if we build on this it to change the values to be different at runtime, the story is a bit more interesting.

```powershell
# from Get-Animal2.ps1
DynamicParam
{
    # create a dictionary to return, and collection of parameters
    $paramDictionary = New-Object -Type System.Management.Automation.RuntimeDefinedParameterDictionary
    $attributeCollection = New-Object -Type System.Collections.ObjectModel.Collection[System.Attribute]

    # create a new [string] parameter for all parameter sets, and decorate with a [ValidateSet]
    $dynParam = New-Object -Type System.Management.Automation.RuntimeDefinedParameter("Animal", [String], $attributeCollection)
    $attributes = New-Object System.Management.Automation.ParameterAttribute
    $fname = "animals.json"
    if ( (Test-Path variable:wild) -and $wild )
    {
        $fname = "wildanimals.json"
    }
    $paramOptions = New-Object System.Management.Automation.ValidateSetAttribute -ArgumentList (ConvertFrom-Json (Get-Content (join-path $PSScriptRoot $fname) -Raw))

    # hook things together
    $attributeCollection.Add($attributes)
    $attributeCollection.Add($paramOptions)
    $paramDictionary.Add("Animal", $dynParam)

    return $paramDictionary
}
```
Now the actual set of valid values is dynamic (read from a file in this case), and which set of values is valid depends on the -wild switch


And that’s a quick way to make a dynamic parameter. But what about all those long names of .NET classes I have to remember? Well, here’s a little code I wrote, you might to read it line for line (sorry if you have Don’t Worry Be Happy playing in your head right now). This function,
New-ValidateSetParameter, takes all that code and makes it one line. To use it you just call it in your DynamicParam block for each dynamic parameter you want to add. So now the first example will be:

```powershell
# From Get-Animal3.ps1, Get-Animal1 using New-ValidateSetParameter
DynamicParam
{
    . (Join-Path $PSScriptRoot "New-ValidateSetParameter.ps1")
    return New-ValidateSetParameter -ParameterName "Animal" -ValidateSet 'cow','pig','horse'
}
```
And the more dynamic version would look like this. See repository for even more examples.

```powershell
# From Get-Animal4.ps1, Get-Animal2 using New-ValidateSetParameter
DynamicParam
{
    . (Join-Path $PSScriptRoot "New-ValidateSetParameter.ps1")

    return New-ValidateSetParameter -ParameterName "Animal" -ValidateSetScript {
        $fname = "animals.json"
        if ( (Test-Path variable:wild) -and $wild )
        {
            $fname = "wildanimals.json"
        }
        return (ConvertFrom-Json (Get-Content (join-path $PSScriptRoot $fname) -Raw))
    }
}
```
Check out the source and help for New-ValidateSetParameter since it has more parameters than I’ve shown here. Even though using dynamic parameters is a user interaction, the code has Pester tests that do testing of valid and invalid parameters passed into functions.

## Debugging and Gotchas
You can debug DynamicParam blocks via the debugger but sometimes it can be tricky. Output such as Write-Verbose/Warning, etc. isn’t written out to the console. In the New-ValidateSetParameter function there is an optional -DebugFile switch that will dump diagnostics out to a file. Also, if you use -ValidateScriptBlock parameter, you can call the  Write-ValidateSetLog($msg) function inside the scriptblock passed to it.

If tabbing isn’t working, sometimes pressing enter will show an error.

### Quirks in Position
Everyone knows you should always use parameter name and for dynamic parameters if you do so, all is well. But if you want to omit parameter names and use positional parameters, things get quirky. In the case when all the parameters are dynamic, things work fine. You can set the position and just type values.

```powershell
# From Get-AnimalAndColor
DynamicParam
{
    . (Join-Path $PSScriptRoot "New-ValidateSetParameter.ps1")
    return New-ValidateSetParameter -ParameterName "Animal" -ValidateSet 'cow','pig','horse' -Mandatory -Position 0 |
           New-ValidateSetParameter -ParameterName "Color" -ValidateSet 'red','blue','green' -Mandatory -Position 1
}
```
If you have dynamic and static parameters, it always thinks the static ones come first, regardless of Postion values. If you want the dynamic parameter first, with other static parameters, it will work if you turn off PositionalBinding and do not use Position, but you have to supply the name for the static parameter. See Get-AnimalStaticColorDynamicFirst.

### Must have [CmdletBinding] or [Parameter]
If nothing seems to be working, and pressing enter shows nothing, it may be you are missing either [CmdletBinding()] or mark one or more static parameters with [Parmeter()]. It seems that without one of those the DynamicParam block is not executed.

## Final Thoughts
I hope this has provided you another tool in your PowerShell toolbox. It’s not often that I’ve needed this, but it sure does make things nicer for the user when there’s a restricted set of valid values. Letting them tab to discover the values is much nicer as opposed to, heaven forbid, read your finely crafted help text.

In the next episode, I’ll take dynamic parameter to the next level and have values and parameters become totally dynamic.

Links
Sample code for this blog on GitHub
Part 2 uses Register-ArgumentCompleter
about_Function_Advanced_Parameter Microsoft’s help on parameters
joat-config on GitHub where I first created a DynamicParameter helper function
PowerShell in Action is a great book on PowerShell
