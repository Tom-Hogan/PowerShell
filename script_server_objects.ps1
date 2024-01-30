<# ================================================================================================
Purpose:
    Creates a series of scripts to create SQL Server level objects for the given server(s).  These 
    can be used to recreate anything deleted by accident or "clone" the objects on a new server.
    Uses the SMO scripter object to create the scripts.  Each object gets its own script.

Notes:    
    Update script list definition in try / catch block if you need to filter for specific files.

History:
    2017-06-01  Tom Hogan           Created.
================================================================================================ #>
Import-Module SqlServer -DisableNameChecking;


$base_directory = 'C:\Scripts\'; # specify output location
$server_list = @(                # specify list of SQL servers
    'SERVER01',
    'SERVER02',
    'SERVER03'
);


<#  ------------------------------------------------------------------------------------------------
    work through each server and build scripts
    --------------------------------------------------------------------------------------------- #>
ForEach ($item in $server_list) { 
    # specify target server
    $sql_server = $item;    # pulling from a table -> $sql_server = $item.server_name; 
    $current_server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server $sql_server;

    # set server directory path
    $clean_sql_server = $sql_server -Replace '\\', '-';
    $server_directory = $base_directory + $clean_sql_server + '\';

    # build server folder
    If ((Test-Path -Path "$server_directory") -eq $False)
        { New-Item -Path $server_directory -Type Directory -Force };

    # remove existing objects
    Get-ChildItem -Path $server_directory -Include *.sql -Recurse | Remove-Item -Force -ErrorAction SilentlyContinue;

    # get server-level objects to script
    $server_objects  = $current_server.BackupDevices;
    $server_objects += $current_server.Endpoints;
    $server_objects += $current_server.JobServer.Jobs | Where-Object { $_.Category -ne 'Report Server' };
    $server_objects += $current_server.LinkedServers;
    $server_objects += $current_server.Triggers;
    $server_objects += $current_server.Logins;
    $server_objects += $current_server.Roles | Where-Object { $_.IsFixedRole -eq $False -and $_.Name -ne "public" };

    ForEach ($script_text in $server_objects | Where-Object { !($_.IsSystemObject) }) {
        if ( $null -ne $script_text ) {
            # build output file name and location   
            $type_directory = $script_text.GetType().Name;
            $output_directory = $server_directory + $type_directory + '\';
            $output_name = $script_text -Replace '[\\\/\:\.]', '-';
            $output_name = $output_name -replace '\[\]', '';
            $output_file = $output_directory + $output_name + '.sql';

            # set options for object creation
            $script_create = New-Object ('Microsoft.SqlServer.Management.Smo.Scripter') ($current_server);
            $script_create.Options.ScriptBatchTerminator = $True;
            $script_create.Options.ToFileOnly = $True;
            $script_create.Options.AppendToFile = $True;
            $script_create.Options.AllowSystemObjects = $False;
            $script_create.Options.Permissions = $True;
            $script_create.Options.DriAll = $True;
            $script_create.Options.ScriptDrops = $False;
            $script_create.Options.IncludeHeaders = $False;
            $script_create.Options.WithDependencies = $False;
            $script_create.Options.IncludeDatabaseRoleMemberships = $True;
            $script_create.Options.LoginSid = $True;
            $script_create.Options.FileName = $output_file;

            # set options for object drop
            $script_drop = New-Object ('Microsoft.SqlServer.Management.Smo.Scripter') ($current_server);
            $script_drop.Options.ScriptBatchTerminator = $True;
            $script_drop.Options.ToFileOnly = $True;
            $script_drop.Options.AppendToFile = $True;
            $script_drop.Options.AllowSystemObjects = $False;
            $script_drop.Options.Permissions = $True;
            $script_drop.Options.DriAll = $True;
            $script_drop.Options.ScriptDrops = $True;
            $script_drop.Options.IncludeHeaders = $False;
            $script_drop.Options.WithDependencies = $False;
            $script_drop.Options.IncludeDatabaseRoleMemberships = $True;
            $script_drop.Options.LoginSid = $True;
            $script_drop.Options.FileName = $output_file;
            
            # build folder structures
            If ((Test-Path -Path "$output_directory") -eq $False)
                { New-Item -Path $output_directory -Type Directory -Force };

            # create script for object
            try {
                $script_drop.EnumScript($script_text);
                $script_create.EnumScript($script_text);
            }
            catch {
                $error[0] | format-list -force;
            };
        };
    };
};
