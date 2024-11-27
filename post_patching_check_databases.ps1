<# ================================================================================================
Purpose:
    Uses the DBA Tools module to get basic info about the databases on a given list of servers.
    Used to validate availability of databases post patching.

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
    Get-DbaDatabase | 
        Select-Object ComputerName, Name, Status, RecoveryModel, @{n = 'Compatibility'; e = { $_.CompatibilityLevel -Replace 'Version', '' } }, Owner, Collation, LastFullBackup, IsSystemObject |
        Sort-Object -Property @{ Expression = 'ComputerName'; Ascending = $true },
                              @{ Expression = 'IsSystemObject'; Descending = $true },
                              @{ Expression = 'Name'; Ascending = $true } |
        Out-GridView;
}
catch {
    # do nothing
};    
