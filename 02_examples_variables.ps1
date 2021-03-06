# PowerShell variables start with a $
$string = 'This is a variable';
$string;

# We can use Get-Member to find out all the information on our objects
$string | Get-Member;

#
# PowerShell is strongly types and uses .Net objects
#
# Not just limited to strings and integers
$date = Get-Date;
$date;
$date | Get-Member;

# Because they are .Net types / classes, we can use methods and properties
$date.Day;
$date.DayOfWeek;
$date.DayOfYear;
$date.ToUniversalTime();

# PowerShell tries to figure out the variable type when it can (implicit types)
# We can explicitly declare our type
[string]$DateString = Get-Date;  # could also use [System.String]
$DateString;
$DateString | Get-Member;

# EVERYTHING is an object.  This means more than just basic types.
$file = New-Item -ItemType File -Path 'C:\PS_Demo\junk_file.txt';
$file | Get-Member;

$file.Name;
$file.FullName;
$file.Extension;
$file.LastWriteTime;

Remove-Item $file;  # clean up file created above;
