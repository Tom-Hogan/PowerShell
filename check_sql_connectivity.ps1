<# ================================================================================================
Purpose:
    Gets the SQL service status for a given list of Servers.

History:
    2017-06-01  Tom Hogan           Created.
================================================================================================ #>
# load needed module(s)
Import-Module SqlServer -DisableNameChecking;


# specify list of SQL Servers
$server_list = @( 
    'SERVER01', 
    'SERVER02' )
;                                        

# variables to be used as part pf check
$sql = "SELECT @@servername AS name, create_date FROM sys.databases WHERE name ='tempdb'";  # query to check last time SQL server was started
$return = @();                                                                              # create empty hash table


# check SQL Server status
ForEach ($instance in $server_list) {
    try {
        $row = New-Object -TypeName PSObject -Property @{'InstanceName' = $instance; 'StartupTime' = $null};
        $check = Invoke-Sqlcmd -ServerInstance $instance -Database tempdb -Query $sql -ErrorAction Stop -ConnectionTimeout 30;
        $row.InstanceName = $check.name;
        $row.StartupTime = $check.create_date;
    }
    catch{
        # do nothing
    }
    finally {
        $return += $row;
    }
};

$return | Format-Table;
