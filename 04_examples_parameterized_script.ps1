<#

.Synopsis
    Creates a CSV that contains the names of the company-specific folders to be uploaded.

.Description
    Creates a CSV that contains the names of the company-specific folders that hold the files to be
    uploaded.

    The CSV is used as a lookup table by another process to get the folder for a given company.  The
    file contains these columns:
    - Company Code is derived from the first 5 characters of the company folder name as they follow 
      a format of <company code> - <company name>.
    - State is hard-coded and set using the $xx_code variables.
    - Company Folder is the folder name.  
    The parent folder and company name part can change from year to year which is why we use the
    CSV as a lookup.

.Parameter ma_folder
    Specifies the location of the Reports folder under the Massachusetts parent folder.

.Parameter nh_folder
    Specifies the location of the Reports folder under the New Hampshire parent folder.

.Parameter csv_file
    Specifies location and name of CSV file to be created.

.Parameter ma_state_code
    Specifies Massachusetts state code, only used for reference inside the CSV.

.Parameter nh_state_code
    Specifies New Hampshire state code, only used for reference inside the CSV.

.Example
    .\04_examples_parameterized_script.ps1 -ma_folder "\file_server\MA" -nh_folder "\\file_server\NH" -csv_file "C:\Temp\REF_companh_folders.csv"

.Example
    .\04_examples_parameterized_script.ps1 -ma_folder "\file_server\MA" -nh_folder "\\file_server\NH" -csv_file "C:\Temp\REF_companh_folders.csv" -ma_state_code MA - nh_state-code NH

.Notes
    2018-07-05  Tom Hogan           Created.

#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ma_folder = '\\file_server\DATA\To_Be_Uploaded\MA\Reports',
    [Parameter(Mandatory=$true)]
    [string]$nh_folder = '\\file_server\DATA\To_Be_Uploaded\NH\Reports',
    [Parameter(Mandatory=$true)]
    [string]$csv_file = 'C:\Temp\REF_companh_folders.csv',
    [string]$ma_state_code ='MA',
    [string]$nh_state_code ='NH'
);


# add MA company folders to CSV file
# recreate file if it already exists
Get-ChildItem -Directory $ma_folder |
    Select-Object @{n='Company_Code'; e={$_.Name.SubString(0, 5)}}, @{n='State'; e={$ma_state_code}}, @{n='Company_Folder'; e={$_.Name}} |
    Export-Csv -Path $csv_file -NoTypeInformation -Force;


# add NH company folders to CSV file
Get-ChildItem -Directory $nh_folder |
    Select-Object @{n='Company_Code'; e={$_.Name.SubString(0, 5)}}, @{n='State'; e={$nh_state_code}}, @{n='Company_Folder'; e={$_.Name}} |
    Export-Csv -Path $csv_file -NoTypeInformation -Append;
