<# ================================================================================================
Purpose:
    Gets basic information about the databases on the given list of SQL Servers and outputs to a CSV
    file.  The list of SQL Servers is pulled from a table in a SQL Server database.

History:
    2017-06-28  Tom Hogan           Created.
================================================================================================ #>
# load needed module(s)
Import-Module SqlServer -DisableNameChecking;


$source_server   = 'DBASQLPROD01';                              # server that holds the server names / settings
$source_database = 'DBA_tools';                                 # database that holds the server names / settings
$output_path     = '\\file_server\DBA\SQL_Server_inventory\';   # output folder


# specify query to pull the list of SQL Servers
$sql = @"
SELECT      s.server_name
,           CASE
                WHEN e.environment_code = 'STG'
                    THEN 'DEV'
                ELSE e.environment_code
            END     AS server_category
FROM        dbo.server_info     AS s
JOIN        dbo.environment     AS e    ON  e.environment_id = s.environment_id
WHERE       s.pull_for_inventory = 1 
AND         s.is_active = 1
ORDER BY    server_category DESC
,           server_name
"@;


# -------------------------------------------------------------------------------------------------
# map network share
# -------------------------------------------------------------------------------------------------
New-PSDrive -Name T -PSProvider FileSystem -Root $output_path | Out-Null;
$output_file = 'T:\Databases.csv';
$error_file = 'T:\Databases_error.log';


# -------------------------------------------------------------------------------------------------
# call the command to build the server list
# -------------------------------------------------------------------------------------------------
$server_list = Invoke-Sqlcmd -Query $sql -ServerInstance $source_server -Database $source_database;


# -------------------------------------------------------------------------------------------------
# remove existing file(s)
# -------------------------------------------------------------------------------------------------
Remove-Item -Path $output_file -ErrorAction SilentlyContinue;
Remove-Item -path $error_file -ErrorAction SilentlyContinue;


# -------------------------------------------------------------------------------------------------
# work through each server and output database info
# -------------------------------------------------------------------------------------------------
ForEach($item in $server_list) { 
    $sql_server = $item.server_name;
    $server_category = $item.server_category;

    try {
        $current_server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server $sql_server;
        $databases = $current_server.Databases;

        # add database info to CSV
        $databases | 
            Select-Object @{n='ServerName'; e={$current_server.Name}}, @{n='ServerCategory'; e={$server_category}}, Name, CreateDate, Status, @{n='CompatibilityLvl'; e={$_.CompatibilityLevel -Replace "Version", ""}}, RecoveryModel, ReadOnly, Size, @{n='DataSpaceUsedMB'; e={$_.DataSpaceUsage / 1024}}, @{n='IndexSpaceUsedMB'; e={$_.IndexSpaceUsage / 1024}}, @{n='SpaceAvailableMB';e={$_.SpaceAvailable / 1024}}, @{n = 'TableCount'; e = {$_.tables.count}} | 
            Export-Csv $output_file -Append -NoTypeInformation;
    }
    catch {
        'Unable to connect to ' + $sql_server | Out-File -Append -FilePath $error_file;
    }
};


# -------------------------------------------------------------------------------------------------
# clean up drive mapping
# -------------------------------------------------------------------------------------------------
Remove-PSDrive -Name T;
