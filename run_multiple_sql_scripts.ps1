<# ================================================================================================
Purpose:
    Applies a set of SQL scripts in a given folder (can be all files in the folder or a defined
    subset) to a defined list of SQL Servers.  Outputs results to a file.  Creates an error file 
    if there are any errors when applying a script.

Notes:    
    Update script list definition in try / catch block if you need to filter for specific files.

History:
    2017-06-01  Tom Hogan           Created.
================================================================================================ #>
Import-Module SqlServer -DisableNameChecking;


$input_path  = 'C:\_SQL-Queries\';          # specify location that holds the SQL scripts to be run
$output_path = 'C:\_SQL-Queries\_Output\';  # specify location for log files
$server_list = @(                           # specify list of SQL Servers
    'SERVER01',
    'SERVER02',
    'SERVER03'
);


# define log file(s)
$output_file = $output_path + 'script_run_log.txt';
$error_file  = $output_path + 'script_run_errors.txt';


<#  -----------------------------------------------------------------------------------------------
    delete output and error files if they exist
    -------------------------------------------------------------------------------------------- #>
Remove-Item $output_file -Force -ErrorAction SilentlyContinue;
Remove-Item $error_file -Force -ErrorAction SilentlyContinue;


<#  ------------------------------------------------------------------------------------------------
    run script(s) against each server
    --------------------------------------------------------------------------------------------- #>
ForEach ($item in $server_list) { 
    try {
        $script_list = Get-ChildItem -Path $input_path |
            Where-Object { $_.name -like 'sp_*.sql' -or $_.name -like 'who_*.sql' -or $_.name -like 'maint*.sql' -or $_.name -like 'Install-Core-Blitz*.sql' } |
            Sort-Object name;

        ForEach ($file in $script_list) {
            $input_file = $file;
            Invoke-Sqlcmd -ServerInstance $item -Database 'master' -InputFile $input_file -TrustServerCertificate -ErrorAction Stop;

            $message = $item + ' - Applied ' + $input_file;
            $message | Out-File -FilePath $output_file -Append;
        }
    }
    catch {
        $message = $item + ' - Error applying ' + $input_file + "`r`n    " + $_.Exception.message;
        $message | Out-File -FilePath $error_file -Append;
    };
};
