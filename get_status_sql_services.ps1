<# ================================================================================================
Purpose:
    Gets the status of any SQL Services on the given computer.

History:
    2018-02-15  Tom Hogan           Created.
================================================================================================ #>
# get status of SQL services
Get-CimInstance -ClassName win32_service -ComputerName SERVER01 |   # specify computer name
    Where-Object{$_.DisplayName -like '*SQL*'} |
    Sort-Object State, DisplayName |
    Format-Table -Property DisplayName, State, StartMode, Status
;
