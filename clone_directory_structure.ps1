<# ================================================================================================
Purpose:
    Copies the folder structure (including subfolders) from one directory to another directory.

History:
    2017-06-28  Tom Hogan           Created.
================================================================================================ #>
$source      = '\\file_server\folder_01';   # specify source directory / folder
$destination = '\\file_server\folder_02';   # specify destination directory / folder


<#
    call robocopy to copy folder structure
    /e  = include subfolders including empty ones
    xf = which files to exclude, * means all
#>
robocopy $source $destination /e /xf *;
