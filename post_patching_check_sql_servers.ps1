<# ================================================================================================
Purpose:
    Uses the DBA Tools module to get the SQL service status for a given list of servers.
    Used to validate availability of SQL services post patching.

History:
    2024-01-30  Tom Hogan           Created.
================================================================================================ #>
Import-Module dbatools;

# specify list of SQL servers
$server_list = @(
    'SERVER01',
    'SERVER02',
    'SERVER03'
);

try {
    $server_list |
        Get-DbaService  |
            Select-Object ComputerName, DisplayName, State, StartMode |
            Where-Object StartMode -NE disabled |
            Sort-Object ComputerName, State, DisplayName |
            Out-GridView;
}
catch {
    # do nothing
};
