<# ================================================================================================
Purpose:
    Gets basic information about the SQL Servers on the given list and outputs to a CSV file. The 
    list of SQL Servers is pulled from an array.

History:
    2017-06-28  Tom Hogan           Created.
================================================================================================ #>
Import-Module SqlServer -DisableNameChecking;


$output_file = 'C:\_SQL-Queries\_Output\SQL-Servers.csv'; # specify location and name of output file
$server_list = @(                                         # specify list of SQL servers
    'SERVER01',
    'SERVER02',
    'SERVER03'
);


<#
    drop output file if it exists
#>
Remove-Item $output_file -Force -ErrorAction SilentlyContinue;


<#
    collect SQL Server info
#>
ForEach ($item in $server_list) { 
    try {
        $current_server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server $item;

        # add server info to CSV
        $current_server | 
            Select-Object Name, @{n = 'FullyQualifiedName'; e = { $current_server.Information.FullyQualifiedNetName } }, Platform, OSVersion, Processors, PhysicalMemory, Product, Edition, Version, ProductLevel, UpdateLevel, @{n = 'MaxServerMemory'; e = { $current_server.Configuration.MaxServerMemory.RunValue } }, IsClustered, ServerType, TCPEnabled, NamedPipesEnabled, LoginMode, ServiceName, ServiceAccount, ServiceStartMode, ServiceInstanceID |
            Export-Csv $output_file -Append -NoTypeInformation;
    }
    catch {
        # do nothing
    };
};
