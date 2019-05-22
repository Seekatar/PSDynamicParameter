# Blog Text only (no code)
Second to having objects in the pipeline, one of the best features of PowerShell is tab-completion. Having the ability to discover or guess the names of commands and their parameters greatly increases the productivity of the user, especially when initially using PowerShell.

In this short series of blog posts, I will show how to use tab-completion for your own functions, and how to create dynamic parameters that change the values for tab completion at runtime.

All the source in the blog is available on GitHub here and all of these examples have been run on PowerShell v5 on Windows 10 and PowerShell v6 (PowerShell Core) on Windows 10 and Linux.
Note that as the documentation states, dynamic parameters are a bit harder to discover since Get-Help doesn’t show them, so they are a bit of a double-edged sword, but they are very useful at times. You can still find them with dash then tabbing through parameters. And by using dynamic parameters you can get behavior like the tab completion of commands, such as Get-ChildItem (aka dir or ls) for files, or Stop-Service for services.

For this first post, I’ll show the simplest way to add dynamic parameters. It will be similar to the static ValidateSet attribute that you can put on a parameter (actually, it will be more than similar).

Has there been a time where you’ve said, “Boy, I sure wish I could create the list of animals on-the-fly.” Enter the DynamicParam keyword.

## DynamicParam
This keyword is used similar to the begin, process and end keywords of a cmdlet. You use this block to add one or more parameters on-the-fly and the attributes of those parameters, such as ValidSet. To start with a simple example, this will add a dyn parameter that will enumerate a set of animals.
Running this command, you’ll be able to do -<tab> to see -dyn as a parameter, then tab through the list of animals.


For PSv6 on Linux, tab completion in general behave a bit differently.


To use the value of the dynamic parameter in your Process block, use the $PSBoundParameters dictionary to check if it exists, and then get the value.

You’ll notice I’m using .NET classes from the System.Management.Automation namespace to create the parameter, set its attributes and hook it into the RuntimeDefinedParameterDictionary that the block returns. The middle part of the code is quite analogous to adding a static parameter. The new RuntimeDefinedParameter is like [string] $Animal The new ValidateSetAttribute is like [ValidateSet( 'cow','pig','horse')] Now, this doesn’t get you much, but if we build on this example to change the code to be different at runtime, the story is a bit more interesting.

Now the actual set of valid values is dynamic (read from a file in this case), and which set of values is valid depends on the -wild switch


And that’s a quick way to make a dynamic parameter. But what about all those long names of .NET classes I have to remember? Well, here’s a little code I wrote, you might to read it line for line (sorry if you have Don’t Worry Be Happy playing in your head right now). This function
New-ValidateSetParameter takes all that code and makes it one line. To use it you just call it in your DynamicParam block for each dynamic parameter you want to add. So now the first example will be:

And the more dynamic version would look like this. See the help on the function for even more examples.

Check out the source and help for New-ValidateSetParameter since it has more parameters than I’ve shown here. Even though using dynamic parameters is a user interaction, the code has Pester tests that do testing of valid and invalid parameters passed into functions.

### Debugging and Gotchas
You can debug DynamicParam blocks via the debugger but sometimes it can be tricky. Output such as Write-Verbose/Warning, etc. isn’t written out to the console. In the New-ValidateSetParameter function there is an optional -DebugFile switch that will dump diagnostics out to a file. Also, if you use -ValidateScriptBlock parameter, you can call the logit($msg) function inside the ScriptBlock passed to it.

If tabbing isn’t working, sometimes pressing enter will show an error.

### Quirks in Position
Everyone knows you should always use parameter name and for dynamic parameters if you do so, all is well. But if you want to omit parameter names and use positional parameters, things get quirky. In the case when all the parameters are dynamic, things work fine. You can set the position and just type values.

If you have dynamic and static parameters, it always thinks the static ones come first, regardless of Postion values. If you want the dynamic parameter first, with other static parameters, it will work if you turn off PositionalBinding and do not use Position, but you have to supply the name for the static parameter. See Get-AnimalStaticColorDynamicFirst.

### Must have [CmdletBinding] or [Parameter]
If nothing seems to be working, and pressing enter shows nothing, it may be you are missing either [CmdletBinding()] or mark one or more static parameters with [Parmeter()]. It seems that without one of those the DynamicParam block is not executed.

## Final Thoughts
I hope this has provided you another tool in your PowerShell toolbox. It’s not often that I’ve needed this, but it sure does make things nicer for the user when there’s a restricted set of valid values. Letting them tab to discover the values is much nicer as opposed to, heaven forbid, read your finely crafted help text.

In the next episode, I’ll take dynamic parameter to the next level and have values and parameters become totally dynamic.

## Links
Sample code for this blog on GitHub
about_Function_Advanced_Parameter Microsoft’s help on parameters
joat-config on GitHub where I first created a DynamicParameter helper function
PowerShell in Action is a great book on PowerShell