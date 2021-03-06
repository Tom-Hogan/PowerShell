# CmdLets - the core functionality
# Get-Date, Verb-Noun
Get-Date;

# What if we wanted to see all the verbs?
Get-Verb;

# Get-Command, the dictionary lookup
Get-Command;
Get-Command -Name *New*;

# Get-Help, describing a specific cmdlet
Get-Help Get-Command;
Get-Help Get-Command -Full;
Get-Help Get-Command -ShowWindow;
Get-Help Get-Command -Online;

# Help is for more than just cmdlets
Get-Help about*;


# Practical use
Get-Command 'New*Item*';

Get-Help New-Item -ShowWindow;

#
# Aliases are handy, they can be used for short hand
#
# Get-ChildItem gets all the contents of a directory
Get-ChildItem C:\;

# dir is an alias for Get-ChildItem
dir C:\;

# We can see all the aliases for a cmdlet
Get-Alias -Definition Get-ChildItem;

# Use a different alias
ls C:\;
