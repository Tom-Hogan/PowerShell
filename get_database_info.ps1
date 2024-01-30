<# ================================================================================================
Purpose:
    Gets basic information about the databases on the given list of SQL Servers and outputs to a CSV
    file.  The list of SQL Servers is pulled from an array.

History:
    2017-06-28  Tom Hogan           Created.
================================================================================================ #>
Import-Module SqlServer -DisableNameChecking;


$output_file = 'C:\_SQL-Queries\_Output\SQL-Databases.csv'; # specify location and name of output file (local path)
$server_list = @(                                           # specify list of SQL servers
    'SERVER01',
    'SERVER02',
    'SERVER03'
);


<#  -----------------------------------------------------------------------------------------------
    drop output file if it exists
    -------------------------------------------------------------------------------------------- #>
Remove-Item $output_file -Force -ErrorAction SilentlyContinue;


<#  -----------------------------------------------------------------------------------------------
    collect SQL Server database info
    -------------------------------------------------------------------------------------------- #>
ForEach ($item in $server_list) { 
    try {
        $current_server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server $item;
        $databases = $current_server.Databases;

        # add database info to CSV
        $databases | 
            Select-Object @{n = 'Server'; e = { $_.Parent } }, Name, Owner, RecoveryModel, @{n = 'CompatibilityLevel'; e = { $_.CompatibilityLevel -Replace 'Version', '' } }, UserAccess, Collation, ReadOnly, Size, @{n = 'DataSpaceUsedMB'; e = { ($_.DataSpaceUsage / 1024).ToString('F2') } }, @{n = 'IndexSpaceUsedMB'; e = { ($_.IndexSpaceUsage / 1024).ToString('F2') } }, @{n = 'SpaceAvailableMB'; e = { ($_.SpaceAvailable / 1024).ToString('F2') } }, AutoCreateStatisticsEnabled, AutoUpdateStatisticsEnabled, AutoShrink, Status, CreateDate, PrimaryFilePath |
            Export-Csv $output_file -Append -NoTypeInformation;
    }
    catch {
        # do nothing
    };
};
