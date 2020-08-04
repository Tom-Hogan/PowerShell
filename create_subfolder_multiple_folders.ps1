<# ================================================================================================
Purpose:
    Creates subfolder(s) with the same name in all folders under a given parent.

History:
    2017-06-28  Tom Hogan           Created.
================================================================================================ #>
$dir = '\\file_server\folder_01';    # specify parent directory / folder (omit last backslash)


# work though the folders and create the subdirectory (or subdirectories)
ForEach($folder in (Get-ChildItem $dir -Directory)) {
    New-Item -ItemType Directory -Path ($folder.FullName + '\subfolder_01');
    New-Item -ItemType Directory -Path ($folder.FullName + '\subfolder_02');
};
