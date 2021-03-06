# Start exploring your objects by piping to Get-Member
[string]$string = 'Earl Grey, hot.';
$string | Get-Member;

# You can also measure collections using Measure-Object
Get-Help about* | Measure-Object;

# We can use the pipeline to quickly write out a text file
New-Item -ItemType Directory -Path 'C:\PS_Demo';
'The quick brown fox jumps over the lazy dog.' | Out-File -FilePath 'C:\PS_Demo\Dummy.txt';
notepad 'C:\PS_Demo\Dummy.txt';

# We can also use it for removing things
New-Item -ItemType File -Path 'C:\PS_Demo\Junk1.txt';
New-Item -ItemType File -Path 'C:\PS_Demo\Junk2.txt';
New-Item -ItemType File -Path 'C:\PS_Demo\Junk3.txt';
New-Item -ItemType File -Path 'C:\PS_Demo\Junk4.txt';

cls;
dir C:\PS_Demo;

dir C:\PS_Demo | Remove-Item;

cls;
dir C:\PS_Demo;


#
# let's start expanding to other commands
#
# Getting free space information

# Getting free space for disk volumes uses win32_Volume
Get-CimInstance -ClassName win32_volume -ComputerName SERVER01 |
    Where-Object {$_.DriveType -eq 3 -and $_.Label -ne 'System Reserved'} |
    Sort-Object name |
    Format-Table Name, Label, @{l = 'Size (GB)'; e = {($_.capacity/1gb).ToString('F2')}}, @{l = 'Free Space (GB)'; e = {($_.freespace/1gb).ToString('F2')}}, @{l = 'Percent Free'; e = {($_.freespace / $_.capacity).ToString('F2')}}
;


# clean out 'old' transaction log backups
Get-ChildItem '\\File_Server\C$\Backups' -Recurse |
    Where-Object {$_.Extenion -eq '.trn' -and $_.LastWriteTime -lt (Get-Date).AddHours(-3)} |
    Remove-Item -WhatIf
;
