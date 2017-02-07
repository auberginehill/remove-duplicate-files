<#
Remove-DuplicateFiles.ps1
#>


[CmdletBinding()]
Param (
    [Parameter(ValueFromPipeline=$true,
    ValueFromPipelineByPropertyName=$true,
    Mandatory=$true,
      HelpMessage="`r`nWhich folder, directory or path would you like to target? `r`n`r`nPlease enter a valid file system path to a directory (a full path name of a directory (a.k.a. a folder) i.e. folder path such as C:\Windows). `r`n`r`nNotes:`r`n`t- If the path name includes space characters, please enclose the path name in quotation marks (single or double). `r`n`t- To stop entering new values, please press [Enter] at an empty input row (and the script will run). `r`n`t- To exit this script, please press [Ctrl] + C`r`n")]
    [ValidateNotNullOrEmpty()]
    [Alias("Start","Begin","Folder","From")]
    [string[]]$Path,
    [Alias("ReportPath")]
    [string]$Output = "$env:temp",
    [ValidateScript({
        # Credit: Mike F Robbins: "PowerShell Advanced Functions: Can we build them better?" http://mikefrobbins.com/2015/03/31/powershell-advanced-functions-can-we-build-them-better-with-parameter-validation-yes-we-can/
        If ($_ -match '^(?!^(PRN|AUX|CLOCK\$|NUL|CON|COM\d|LPT\d|\..*)(\..+)?$)[^\x00-\x1f\\?*:\"";|/]+$') {
            $True
        } Else {
            Throw "$_ is either not a valid filename or it is not recommended. If the filename includes space characters, please enclose the filename in quotation marks."
        }
    })]
    [Alias("File")]
    [string]$FileName = "deleted_files.txt",
    [switch]$Recurse,
    [switch]$Audio
)




Begin {


    # Establish some common variables
    $ErrorActionPreference = "Stop"
    $computer = $env:COMPUTERNAME
    $empty_line = ""
    $list = $null
    $folders = @()
    $results = @()
    $skipped = @()
    $duplicate_files = @()
    $skipped_path_names = @()
    $number_of_paths = $Path.Count
    $number_of_duplicate_files = 0


    # A function to calculate hash values in PowerShell versions 2 and 3
    # Requires .NET Framework v3.5
    # Example: dir C:\Temp | Check-FileHash
    # Example: Check-FileHash C:\Windows\explorer.exe -Algorithm SHA1
    # Source: http://poshcode.org/2154
    # Credit: Lee Holmes: "Windows PowerShell Cookbook (O'Reilly)" (Get-FileHash script) http://www.leeholmes.com/guide

    Function Check-FileHash {

        param(
        $hash_path,
        [ValidateSet("MD5","SHA1","SHA256","SHA384","SHA512","MACTripleDES","RIPEMD160")]
        $Algorithm = "SHA256"
        )

        $files = @()

        # Create the hash value calculator
        # Source: http://stackoverflow.com/questions/21252824/how-do-i-get-powershell-4-cmdlets-such-as-test-netconnection-to-work-on-windows
        # Source: https://msdn.microsoft.com/en-us/library/system.security.cryptography.sha256cryptoserviceprovider(v=vs.110).aspx
        # Source: https://msdn.microsoft.com/en-us/library/system.security.cryptography.md5cryptoserviceprovider(v=vs.110).aspx
        # Source: https://msdn.microsoft.com/en-us/library/system.security.cryptography(v=vs.110).aspx
        # Source: https://msdn.microsoft.com/en-us/library/system.security.cryptography.mactripledes(v=vs.110).aspx
        # Source: https://msdn.microsoft.com/en-us/library/system.security.cryptography.ripemd160(v=vs.110).aspx
        # Credit: Twon of An: "Get the SHA1,SHA256,SHA384,SHA512,MD5 or RIPEMD160 hash of a file" https://community.spiceworks.com/scripts/show/2263-get-the-sha1-sha256-sha384-sha512-md5-or-ripemd160-hash-of-a-file
        If (($Algorithm -eq "MD5") -or ($Algorithm -like "SHA*")) {
            $typename = [string]"System.Security.Cryptography." + $Algorithm + "CryptoServiceProvider"
            $hasher = New-Object -TypeName $typename
        } ElseIf ($Algorithm -eq "MACTripleDES") {
            $hasher = New-Object -TypeName System.Security.Cryptography.MACTripleDES
        } ElseIf ($Algorithm -eq "RIPEMD160") {
            $hasher = [System.Security.Cryptography.HashAlgorithm]::Create("RIPEMD160")
        } Else {
            $continue = $true
        } # Else

                    # If a file name is specified, add that to the list of files to process
                    If ($hash_path) {
                        $files += $hash_path
                    } Else {
                        # Take the files that are piped into the script
                        $files += @($input | ForEach-Object { $_.FullName })
                    } # Else (If $hash_path)

        ForEach ($file in $files) {

                # Source: http://go.microsoft.com/fwlink/?LinkID=113418
                If ((Test-Path $file -PathType Leaf) -eq $false) {

                    # Skip the item ($file) if it is not a file (return to top of the program loop (ForEach $file)
                    Continue

                } Else {

                    # Convert the item ($file) to a fully-qualified path
                    $filepath = (Resolve-Path $file).Path

                    # Calculate the hash of the file regardless whether it is opened in another program or not
                    # Source: http://stackoverflow.com/questions/21252824/how-do-i-get-powershell-4-cmdlets-such-as-test-netconnection-to-work-on-windows
                    # Credit: Gisli: "Unable to read an open file with binary reader" http://stackoverflow.com/questions/8711564/unable-to-read-an-open-file-with-binary-reader
                    $source_file = [System.IO.File]::Open("$filepath",[System.IO.Filemode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
                    $hash = [System.BitConverter]::ToString($hasher.ComputeHash($source_file)) -replace "-",""
                    $source_file.Close()

                            # Return a custom object with the important details from the hashing
                            # Source: https://msdn.microsoft.com/en-us/library/system.io.path_methods(v=vs.110).aspx
                            $output = New-Object PsObject -Property @{
                                    'FileName'                      = ([System.IO.Path]::GetFileName($file));
                                    'Path'                          = ([System.IO.Path]::GetFullPath($file));
                                    'Directory'                     = ([System.IO.Path]::GetDirectoryName($file));
                                  #  'Extension'                     = ([System.IO.Path]::GetExtension($file));
                                  #  'FileNameWithoutExtension'      = ([System.IO.Path]::GetFileNameWithoutExtension($file));
                                    'Algorithm'                     = $Algorithm;
                                    'Hash'                          = $hash
                            } # New-Object
                } # Else (Test-Path $file)
            $output
        } # ForEach ($file)
    } # function


    # Test if the Output-path ("ReportPath") exists
    If ((Test-Path $Output) -eq $false) {

        $invalid_output_path_was_found = $true

        # Display an error message in console
        $empty_line | Out-String
        Write-Warning "'$Output' doesn't seem to be a valid path name."
        $empty_line | Out-String
        Write-Verbose "Please consider checking that the Output ('ReportPath') location '$Output', where the resulting text file is ought to be written, was typed correctly and that it is a valid file system path, which points to a directory. If the path name includes space characters, please enclose the path name in quotation marks (single or double)." -verbose
        $empty_line | Out-String
        $skip_text = "Couldn't find -Output folder '$Output'..."
        Write-Output $skip_text
        $empty_line | Out-String
        Exit
        Return

    } Else {

        # Resolve the Output-path ("ReportPath") (if the Output-path is specified as relative)
        $real_output_path = Resolve-Path -Path $Output
        $txt_file = "$real_output_path\$FileName"

    } # Else (If Test-Path $Output)


    # Add the user-defined path name(s) to the list of folders to process
    # Source: http://poshcode.org/2154
    # Credit: Lee Holmes: "Windows PowerShell Cookbook (O'Reilly)" (Get-FileHash script) http://www.leeholmes.com/guide
    If ($Path) {

        ForEach ($path_candidate in $Path) {

            # Test if the path exists
            If ((Test-Path $path_candidate) -eq $false) {

                $invalid_path_was_found = $true

                # Increment the error counter
                $num_invalid_paths++

                # Display an error message in console
                $empty_line | Out-String
                Write-Warning "'$path_candidate' doesn't seem to be a valid path name."
                $empty_line | Out-String
                Write-Verbose "Please consider checking that the starting point location (the '-Path' variable value of) '$path_candidate' was typed correctly and that it is a valid file system path, which points to a directory. If the path name includes space characters, please enclose the path name in quotation marks (single or double)." -verbose
                $empty_line | Out-String
                $skip_text = "Skipping '$path_candidate' from the results."
                Write-Output $skip_text

                    # Add the invalid path as an object (with properties) to a collection of skipped paths
                    $skipped += $obj_skipped = New-Object -TypeName PSCustomObject -Property @{

                                'Skipped Paths'         = $path_candidate
                                'Owner'                 = ""
                                'Created on'            = ""
                                'Last Updated'          = ""
                                'Size'                  = "-"
                                'Error'                 = "The path was not found on $computer."
                                'raw_size'              = 0

                        } # New-Object

                # Add the invalid path name to a list of failed path names
                $skipped_path_names += $path_candidate

                # Return to top of the program loop (ForEach $path_candidate) and skip just this iteration of the loop.
                Continue

            } Else {

                # Resolve path (if path is specified as relative)
                $full_path = (Resolve-Path $path_candidate).Path
                $folders += $full_path


                # If the Recurse parameter was used, add the recursively detected folder names to the list of folders to process
                # Credit: Mekac: "Get folder where Access is denied" https://social.technet.microsoft.com/Forums/en-US/4d78bba6-084a-4a41-8d54-6dde2408535f/get-folder-where-access-is-denied?forum=winserverpowershell
                If ($Recurse) {

                    $available_folders = Get-ChildItem $full_path -Recurse:$Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer -eq $true } | Select-Object FullName, @{ Label="AclDenied"; Expression={ (Get-Acl $_.FullName).AreAccessRulesProtected }} | Where-Object { $_.AclDenied -eq $false } | Sort FullName | Select-Object -ExpandProperty FullName

                    $unavailable_folders = Get-ChildItem $full_path -Recurse:$Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer -eq $true } | Select-Object FullName, @{ Label="AclDenied"; Expression={ (Get-Acl $_.FullName).AreAccessRulesProtected }} | Where-Object { $_.AclDenied -eq $null } | Sort FullName | Select-Object -ExpandProperty FullName

                                If ($available_folders -eq $null) {
                                    $continue = $true
                                } Else {
                                    ForEach ($directory in ($available_folders)) {

                                        # Increment the number of paths to process counter
                                        $number_of_paths++

                                        # Resolve path
                                        $real_path = (Resolve-Path $directory).Path
                                        $folders += $real_path
                                    } # ForEach $directory
                                } # else (if $available_folders.Count)

                        If ($unavailable_folders -eq $null) {
                            $continue = $true
                        } Else {
                            $invalid_path_was_found = $true
                            ForEach ($item in ($unavailable_folders)) {

                                # Increment the error counter
                                $num_invalid_paths++

                                # Add the invalid path as an object (with properties) to a collection of skipped paths
                                $skipped += $obj_skipped = New-Object -TypeName PSCustomObject -Property @{

                                            'Skipped Paths'         = $item
                                            'Owner'                 = ""
                                            'Created on'            = ""
                                            'Last Updated'          = ""
                                            'Size'                  = "-"
                                            'Error'                 = "The path could not be opened (access denied)."
                                            'raw_size'              = 0

                                    } # New-Object

                                # Add the invalid path name to a list of failed path names
                                $skipped_path_names += $path_candidate
                            } # ForEach $item
                        } # else (if $unavailable_folders.Count)
                } Else {
                    $continue = $true
                } # Else (If $Recurse)
            } # Else (If Test-Path $path_candidate)
        } # ForEach $path_candidate

    } Else {
        # Take the files that are piped into the script
        $folders += @($input | ForEach-Object { $_.FullName })
    } # Else (If $Path)


    <#
                # Get MD5 hash and SHA256 hash values from one file with PowerShell version 2
                # Requires .NET Framework v3.5
                # Source: http://stackoverflow.com/questions/21252824/how-do-i-get-powershell-4-cmdlets-such-as-test-netconnection-to-work-on-windows
                # Source: https://msdn.microsoft.com/en-us/library/system.security.cryptography.sha256cryptoserviceprovider(v=vs.110).aspx
                # Source: https://msdn.microsoft.com/en-us/library/system.security.cryptography.md5cryptoserviceprovider(v=vs.110).aspx
                # Credit: Gisli: "Unable to read an open file with binary reader" http://stackoverflow.com/questions/8711564/unable-to-read-an-open-file-with-binary-reader
                $source = "C:\Windows\explorer.exe"
                $full_path = (Resolve-Path $source).Path
                $MD5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                $SHA256 = New-Object -TypeName System.Security.Cryptography.SHA256CryptoServiceProvider
                $file = [System.IO.File]::Open("$source",[System.IO.Filemode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
                $hash_MD5 = [System.BitConverter]::ToString($MD5.ComputeHash($file)) -replace "-",""
                $file.Close()
                $file = [System.IO.File]::Open("$source",[System.IO.Filemode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
                $hash_SHA256 = [System.BitConverter]::ToString($SHA256.ComputeHash($file)) -replace "-",""
                $file.Close()

                                $output = New-Object PsObject -Property @{
                                        'File'          = ([System.IO.Path]::GetFileName($full_path));
                                      #  'Directory'     = ([System.IO.Path]::GetDirectoryName($full_path));
                                        'Full Path'     = $full_path;
                                        'MD5'           = $hash_MD5;
                                        'SHA256'        = $hash_SHA256
                                } # New-Object

                $output | select 'File','Full Path','MD5','SHA256' | Format-List
    #>


} # begin




Process {

    # Process each folder
    # Source: http://poshcode.org/2154
    # Credit: Lee Holmes: "Windows PowerShell Cookbook (O'Reilly)" (Get-FileHash script) http://www.leeholmes.com/guide
    $unique_folders = $folders | select -Unique
    ForEach ($folder in $unique_folders) {

        # Source: http://go.microsoft.com/fwlink/?LinkID=113418
        If ((Test-Path $folder -PathType Container) -eq $false) {

            # Skip the item ($folder) if it is not a folder (return to top of the program loop (ForEach $folder)
            Continue

        } Else {

                # Find the duplicate files (including the original file)
                If (($PSVersionTable.PSVersion).Major -ge 4) {
                    # Requires PowerShell version 4.0
                    # Source: https://gist.github.com/quentinproust/8d3bd11562a12446644f
                    # Source: https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/get-filehash
                    $list = dir "$folder" -Force | Get-FileHash -Algorithm SHA256 | Group-Object -Property Hash | Where-Object {( $_.Count -gt 1 )}
                } Else {
                    # Requires PowerShell version 2 (and .NET Framework v3.5)
                    # Credit: Lee Holmes: "Windows PowerShell Cookbook (O'Reilly)" (Get-FileHash script) http://www.leeholmes.com/guide
                    $list = dir "$folder" -Force | Check-FileHash -Algorithm SHA256 | Group-Object -Property Hash | Where-Object {( $_.Count -gt 1 )}
                } # else (If $PSVersionTable.PSVersion)


                # Enumerate the duplicate entities (excluding the original file)
                If ($list.Count -gt 1) {
                    $duplicate_files += $list | ForEach-Object { $_ | select -ExpandProperty Group | select -ExpandProperty Path | select -First ($_.Count -1) }
                    $number_of_duplicate_files += $duplicate_files.Count
                } Else {
                    $continue = $true
                } # else (If $list.Count)
        } # Else (Test-Path $folder)
    } # ForEach ($folder)

                    # Process each file
                    # Source: https://msdn.microsoft.com/en-us/library/system.io.path_methods(v=vs.110).aspx
                    ForEach ($file in $duplicate_files) {

                        $filename = ([System.IO.Path]::GetFileName($file))
                        $dir_path = ([System.IO.Path]::GetFullPath($file))
                        $directory_name = ([System.IO.Path]::GetDirectoryName($file))
                        $extension = ([System.IO.Path]::GetExtension($file))
                        $filename_without_extension = ([System.IO.Path]::GetFileNameWithoutExtension($file))

                                    $results += New-Object -TypeName PSCustomObject -Property @{
                                            'File'          = $filename
                                            'Directory'     = $directory_name
                                            'Extension'     = $extension
                                            'File Name'     = $filename_without_extension
                                            'Full Path'     = $file
                                            'Full_Path'     = $file
                                            'MD5'           = ""
                                            'MACTripleDES'  = ""
                                            'RIPEMD160'     = ""
                                            'SHA1'          = ""
                                            'SHA384'        = ""
                                            'SHA512'        = ""
                                            'SHA256'        = If (($PSVersionTable.PSVersion).Major -ge 4) {
                                                                    Get-FileHash $file -Algorithm SHA256 | Select-Object -ExpandProperty Hash
                                                                } Else {
                                                                    Check-FileHash $file -Algorithm SHA256 | Select-Object -ExpandProperty Hash
                                                                } # else (If $PSVersionTable.PSVersion)
                                    } # New-Object
                    } # ForEach ($file)
} # Process




End {

            # Do the background work for natural language
            If ($unique_folders.Count -gt 1) { $item_text = "paths" } Else { $item_text = "path" }

                If (($invalid_path_was_found) -ne $true) {
                    $enumeration_went_succesfully = $true
                    $empty_line | Out-String
                    $stats_text = "Total $($unique_folders.Count) $item_text processed at $($unique_folders -join ', ')"
                } Else {
                    $enumeration_went_succesfully = $false

                    # Display the skipped path names in console
                    $empty_line | Out-String
                    $skipped.PSObject.TypeNames.Insert(0,"Skipped Path Names")
                    $skipped_selection = $skipped | Select-Object 'Skipped Paths','Size','Error' | Sort-Object 'Skipped Paths'
                    $skipped_selection | Format-Table -auto

                            If ($num_invalid_paths -gt 1) {
                                $stats_text = "Total $($unique_folders.Count) $item_text processed. There were $num_invalid_paths skipped paths."
                            } Else {
                                $stats_text = "Total $($unique_folders.Count) $item_text processed. One path was skipped."
                            } # Else

                } # Else (If $invalid_path_was_found)


    If ($results.Count -ge 1) {

        # Write the operational stats in console
        Write-Output $stats_text
        $empty_line | Out-String


        # Remove the duplicate files
        Remove-Item $duplicate_files -Force


        # Test if the files were removed
        If ((Test-Path $duplicate_files) -eq $true) {
            "Exit Code 1: Something went wrong with the deletion procedure."
            Return $empty_line
        } Else {
                    # Write the header in console
                    $duplicate_files.PSObject.TypeNames.Insert(0,"Duplicate Files")
                    $results.PSObject.TypeNames.Insert(0,"Duplicate Files")
                    $results_selection = $results | select "File","Full Path","SHA256"

                            If ($number_of_duplicate_files -gt 1) {
                                $header = "Duplicate files that were deleted"
                                $coline = "---------------------------------"
                                Write-Output $header
                                $coline | Out-String
                            } ElseIf ($number_of_duplicate_files -eq 1) {
                                $header = "The following duplicate file was deleted"
                                $coline = "----------------------------------------"
                                Write-Output $header
                                $coline | Out-String
                            } Else {
                                    $continue = $true
                            } # else (If $number_of_duplicate_files -gt 1)


                # Write the results in console
                Write-Output $duplicate_files
                Write-Output $results_selection | Format-List


                # Write info about the removed duplicate files to a text file (located at the current temp-folder or the location is defined with the -Output parameter)
                $header_txt = "Deleted Files"
                $separator  = "-------------"

                        If ((Test-Path $txt_file) -eq $false) {
                            ($results_selection | Format-List) | Out-File "$txt_file" -Encoding UTF8 -Force
                            $results_list = Get-Content $txt_file
                            $empty_line  | Out-File "$txt_file" -Encoding UTF8 -Force
                            Add-Content -Path "$txt_file" -Value $header_txt -Encoding UTF8
                            Add-Content -Path "$txt_file" -Value $separator -Encoding UTF8
                            Add-Content -Path "$txt_file" -Value $empty_line -Encoding UTF8
                            Add-Content -Path "$txt_file" -Value $empty_line -Encoding UTF8
                            Add-Content -Path "$txt_file" -Value $duplicate_files -Encoding UTF8
                            Add-Content -Path "$txt_file" -Value $results_list -Encoding UTF8
                            Add-Content -Path "$txt_file" -Value "Date: $(Get-Date -Format g)"
                        } Else {
                            $results_list = ($results_selection | Format-List)
                            $pre_existing_content = Get-Content $txt_file
                            ($pre_existing_content + $empty_line + $empty_line + $separator + $empty_line + $empty_line + $duplicate_files + $results_list) | Out-File "$txt_file" -Encoding UTF8 -Force
                            Add-Content -Path "$txt_file" -Value "Date: $(Get-Date -Format g)"
                        } # Else (If Test-Path $txt_file)

                # Sound the bell if set to do so with the -Audio parameter (ASCII character 7)
                If ( -not $Audio ) {
                        $continue = $true
                } Else {
                        [char]7
                } # else

        } # Else (If Test-Path $duplicate_files)

    } Else {

        $exit_text = "No duplicate files were detected in $($folders -join ', ')"
        Write-Output $exit_text
        $empty_line | Out-String

    } # Else (If $results.Count)

} # End




# [End of Line]


<#


   _____
  / ____|
 | (___   ___  _   _ _ __ ___ ___
  \___ \ / _ \| | | | '__/ __/ _ \
  ____) | (_) | |_| | | | (_|  __/
 |_____/ \___/ \__,_|_|  \___\___|


https://social.technet.microsoft.com/Forums/en-US/4d78bba6-084a-4a41-8d54-6dde2408535f/get-folder-where-access-is-denied?forum=winserverpowershell  # Mekac: "Get folder where Access is denied"
http://mikefrobbins.com/2015/03/31/powershell-advanced-functions-can-we-build-them-better-with-parameter-validation-yes-we-can/                     # Mike F Robbins: "PowerShell Advanced Functions: Can we build them better?"
http://www.leeholmes.com/guide                                                                                          # Lee Holmes: "Windows PowerShell Cookbook (O'Reilly)" (Get-FileHash script)
http://stackoverflow.com/questions/8711564/unable-to-read-an-open-file-with-binary-reader                               # Gisli: "Unable to read an open file with binary reader"
https://community.spiceworks.com/scripts/show/2263-get-the-sha1-sha256-sha384-sha512-md5-or-ripemd160-hash-of-a-file    # Twon of An: "Get the SHA1,SHA256,SHA384,SHA512,MD5 or RIPEMD160 hash of a file"

  _    _      _
 | |  | |    | |
 | |__| | ___| |_ __
 |  __  |/ _ \ | '_ \
 | |  | |  __/ | |_) |
 |_|  |_|\___|_| .__/
               | |
               |_|
#>

<#

.SYNOPSIS
Removes duplicate files within a specified directory or directories.

.DESCRIPTION
Remove-DuplicateFiles searches for duplicate files from a directory specified with
the -Path parameter. Multiple paths may be entered to the -Path parameter (separated
with a comma) and sub-directories may be included as well by adding the -Recurse
parameter to the launching command. The removal of files in Remove-DuplicateFiles
is always done on 'per directory' -basis, so for example if a file exists twice in
Folder A and also once in Folder B, only the second instance of the file in Folder A
would be deleted. The files of a folder are analysed with the inbuilt Get-FileHash 
cmdlet in machines that have PowerShell version 4 or later installed, and in 
machines that are running PowerShell version 2 or 3 the .NET Framework commands 
(and a function called Check-FileHash, which is based on Lee Holmes' Get-FileHash 
script in "Windows PowerShell Cookbook (O'Reilly)" (http://www.leeholmes.com/guide))
are invoked for determining whether or not any duplicate files exist in a 
particular folder.

If deletions are made, a log-file (deleted_files.txt by default) is created to
$env:temp, which points to the current temporary file location and is set in the
system (- for more information about $env:temp, please see the Notes section). The
filename of the log-file can be set with the -FileName parameter (a filename with a
.txt ending is recommended) and the default output destination folder may be changed
with the -Output parameter. During the possibly invoked log-file creation procedure
Remove-DuplicateFiles tries to preserve any pre-existing content rather than
overwrite the specified file, so if the -FileName parameter points to an existing
file, new log-info data is appended to the end of that file.

If the -Audio parameter has been used, an audible beep will be emitted after
Remove-DuplicateFiles has deleted one or more files. Please note that if any of
the parameter values (after the parameter name itself) includes space characters,
the value should be enclosed in quotation marks (single or double) so that
PowerShell can interpret the command correctly.

.PARAMETER Path
with aliases -Start, -Begin, -Folder, and -From. The -Path parameter determines the
starting point of the duplicate file analysation. The -Path parameter also accepts a
collection of path names (separated by a comma). It's not mandatory to write -Path
in the remove duplicate files command to invoke the -Path parameter, as is shown in
the Examples below, since Remove-DuplicateFiles is trying to decipher the inputted
queries as good as it is machinely possible within a 50 KB size limit.

The paths should be valid file system paths to a directory (a full path name of a
directory (i.e. folder path such as C:\Windows)). In case the path name includes
space characters, please enclose the path name in quotation marks (single or double).
If a collection of path names is defined for the -Path parameter, please separate
the individual path names with a comma. The -Path parameter also takes an array of
strings for paths and objects could be piped to this parameter, too. If no path is
defined in the command launching Remove-DuplicateFiles the user will be prompted to
enter a -Path value. Whether or not the subdirectories are added to the list of
folders to be processed is toggled with the -Recurse parameter.

Please note that the removal of files in Remove-DuplicateFiles is always done on
'per directory' -basis, so for example if a file exists twice in Folder A and also
once in Folder B, only the second instance of the file in Folder A would be deleted.
To make Remove-DuplicateFiles analyse all items in every specified directory in one
go may be one of the key areas of further development in Remove-DuplicateFiles.

.PARAMETER Output
with an alias -ReportPath. Specifies where the log-file (deleted_files.txt by
default), which is created or updated when deletions are made, is to be saved.
The default save location is $env:temp, which points to the current temporary file
location, which is set in the system. The default -Output save location is defined
at line 16 with the $Output variable. In case the path name includes space
characters, please enclose the path name in quotation marks (single or double).
For usage, please see the Examples below and for more information about $env:temp,
please see the Notes section below.

.PARAMETER FileName
with an alias -File. The filename of the log-file can be set with the -FileName
parameter (a filename with a .txt ending is recommended, the default filename is
deleted_files.txt). During the possibly invoked log-file creation procedure
Remove-DuplicateFiles tries to preserve any pre-existing content rather than
overwrite the specified file, so if the -FileName parameter points to an existing
file, new log-info data is appended to the end of that file. If the filename
includes space characters, please enclose the filename in quotation marks (single
or double).

.PARAMETER Recurse
If the -Recurse parameter is added to the command launching Remove-DuplicateFiles,
also each and every sub-folder in any level, no matter how deep in the directory
structure or behind how many sub-folders, is added to the list of folders to be
processed by Remove-DuplicateFiles. Since the removal of files in
Remove-DuplicateFiles is always done on 'per directory' -basis and because the
contents of different folders are not compared with each other, those duplicate
files, which exist alone in their own folder will be preserved (and as per default
one instance of a file in each folder) even after Remove-DuplicateFiles has been
run.

If the -Recurse parameter is not used, the only folders that are processed are those
which have been defined with the -Path parameter, and due to the inherent nature of
Remove-DuplicateFiles, where each folder is regarded as an separate entity, the
contents of different folders are not combined nor compared with each other.

.PARAMETER Audio
If this parameter is used in the remove duplicate files command, an audible beep
will occur, if any deletions are made by Remove-DuplicateFiles.

.OUTPUTS
Deletes duplicate files in a folder.
Displays results about deleting duplicate files in console, and if any deletions
were made, writes or updates a logfile (deleted_files.txt) at $env:temp. The
filename of the log-file can be set with the -FileName parameter (a filename with a
.txt ending is recommended) and the default output destination folder may be changed
with the -Output parameter.


    Default values (the log-file creation/updating procedure only occurs if
    deletion(s) is/are made by Remove-DuplicateFiles):


        $env:temp\deleted_files.txt       : TXT-file     : deleted_files.txt


.NOTES
Please note that all the parameters can be used in one remove duplicate files
command and that each of the parameters can be "tab completed" before typing
them fully (by pressing the [tab] key).

Please also note that the possibly generated log-file is created in a directory,
which is end-user settable in each remove duplicate files command with the -Output
parameter. The default save location is defined with the $Output variable (at
line 16). The $env:temp variable points to the current temp folder. The default
value of the $env:temp variable is C:\Users\<username>\AppData\Local\Temp
(i.e. each user account has their own separate temp folder at path
%USERPROFILE%\AppData\Local\Temp). To see the current temp path, for instance
a command

    [System.IO.Path]::GetTempPath()

may be used at the PowerShell prompt window [PS>]. To change the temp folder for
instance to C:\Temp, please, for example, follow the instructions at
http://www.eightforums.com/tutorials/23500-temporary-files-folder-change-location-windows.html

    Homepage:           https://github.com/auberginehill/remove-duplicate-files
    Short URL:          http://tinyurl.com/jv4jlbe
    Version:            1.0

.EXAMPLE
./Remove-DuplicateFiles -Path "E:\chiore"
Run the script. Please notice to insert ./ or .\ before the script name.
Removes duplicate files from the "E:\chiore" directory and saves the generated
log-file at the default location ($env:temp), if any deletions were made. Regardless
of how many subfolders there are or are not in "E:\chiore" the duplicate files are
analysed at the first level only (i.e. the base for the file analysation is
non-recursive, similar to a common command "dir", for example). During the possibly
invoked log-file creation procedure Remove-DuplicateFiles tries to preserve any
pre-existing content rather than overwrite the file, so if the default log-file
(deleted_files.txt) already exists, new log-info data is appended to the end of that
file. Please note, that -Path and the quotation marks can be omitted in this
example, because

    ./Remove-DuplicateFiles E:\chiore

will result in the exact same outcome, since the path name is accepted as a first
defined value automatically and since the path name doesn't contain any space
characters.

.EXAMPLE
help ./Remove-DuplicateFiles -Full
Display the help file.

.EXAMPLE
./Remove-DuplicateFiles -Path "E:\chiore", "C:\dc01" -Output "C:\Scripts"

Run the script and remove all duplicate files from the first level of "E:\chiore"
and "C:\dc01" separately (i.e. those duplicate files, which would be listed with the
"dir E:\chiore" or "dir E:\dc01" command), and if any deletions are made, save
the log-file to C:\Scripts with the default filename (deleted_files.txt). The word
-Path and the quotation marks can be omitted in this example, too. Please note that
due to the inherent nature of Remove-DuplicateFiles, if a file exists in "E:\chiore"
and also in "C:\dc01" (i.e. the other instance is a duplicate file), neither of the 
occurrences would be deleted by Remove-DuplicateFiles, since it treats each 
individual folder as its own separate entity and only removes duplicate files within
an one folder realm.

.EXAMPLE
./Remove-DuplicateFiles -Path "C:\Users\Dropbox" -Recurse

Will delete all duplicate files from C:\Users\Dropbox and will add all
sub-directories of the sub-directories of the sub-directories and their
sub-directories as well to the list of folders to process (the search for folders to
process is done recursively). Looks for duplicate files in each of the found folders
separately and deletes all multiple occurrences of a file within one folder (so if a
file exists twice in Folder A and also once in Folder B, only the second instance of
the file in Folder A would be deleted).

If any deletions were made, the log-file is saved to the default location
($env:temp) with the default filename (deleted_files.txt). The Path variable value
is case-insensitive (as is most of the PowerShell), and since the path name doesn't
contain any space characters, it doesn't need to be enveloped with quotation marks.
Actually the -Path parameter may be left out from the command, too, since, for
example,

    ./Remove-DuplicateFiles c:\users\dROPBOx -Recurse

is the exact same command in nature.

.EXAMPLE
.\Remove-DuplicateFiles.ps1 -From C:\dc01 -ReportPath C:\Scripts -File log.txt -Recurse -Audio

Run the script and delete all duplicate files found in C:\dc01 and in every
subfolder under C:\dc01. The duplicate files are searched in each folder separately
and multiple occurrences of a file are deleted only within one folder (so if a file
exists twice in Folder A and also once in Folder B, only the second instance of the
file in Folder A would be deleted).

If any deletions were made, the log-file would be saved to C:\Scripts with the
filename log.txt and an audible beep would occur. This command will work, because
-From is an alias of -Path and -ReportPath is an alias of -Output and -File is an
alias of -FileName. Furthermore, since the path names don't contain any space
characters, they don't need to be enclosed in quotation marks.

.EXAMPLE
Set-ExecutionPolicy remotesigned
This command is altering the Windows PowerShell rights to enable script execution for
the default (LocalMachine) scope. Windows PowerShell has to be run with elevated rights
(run as an administrator) to actually be able to change the script execution properties.
The default value of the default (LocalMachine) scope is "Set-ExecutionPolicy restricted".


    Parameters:

    Restricted      Does not load configuration files or run scripts. Restricted is the default
                    execution policy.

    AllSigned       Requires that all scripts and configuration files be signed by a trusted
                    publisher, including scripts that you write on the local computer.

    RemoteSigned    Requires that all scripts and configuration files downloaded from the Internet
                    be signed by a trusted publisher.

    Unrestricted    Loads all configuration files and runs all scripts. If you run an unsigned
                    script that was downloaded from the Internet, you are prompted for permission
                    before it runs.

    Bypass          Nothing is blocked and there are no warnings or prompts.

    Undefined       Removes the currently assigned execution policy from the current scope.
                    This parameter will not remove an execution policy that is set in a Group
                    Policy scope.


For more information, please type "Get-ExecutionPolicy -List", "help Set-ExecutionPolicy -Full",
"help about_Execution_Policies" or visit https://technet.microsoft.com/en-us/library/hh849812.aspx
or http://go.microsoft.com/fwlink/?LinkID=135170.

.EXAMPLE
New-Item -ItemType File -Path C:\Temp\Remove-DuplicateFiles.ps1
Creates an empty ps1-file to the C:\Temp directory. The New-Item cmdlet has an inherent -NoClobber
mode built into it, so that the procedure will halt, if overwriting (replacing the contents) of
an existing file is about to happen. Overwriting a file with the New-Item cmdlet requires using
the Force. If the path name and/or the filename includes space characters, please enclose the
whole -Path parameter value in quotation marks (single or double):

    New-Item -ItemType File -Path "C:\Folder Name\Remove-DuplicateFiles.ps1"

For more information, please type "help New-Item -Full".

.LINK
https://social.technet.microsoft.com/Forums/en-US/4d78bba6-084a-4a41-8d54-6dde2408535f/get-folder-where-access-is-denied?forum=winserverpowershell
http://mikefrobbins.com/2015/03/31/powershell-advanced-functions-can-we-build-them-better-with-parameter-validation-yes-we-can/
http://www.leeholmes.com/guide
http://stackoverflow.com/questions/8711564/unable-to-read-an-open-file-with-binary-reader
https://community.spiceworks.com/scripts/show/2263-get-the-sha1-sha256-sha384-sha512-md5-or-ripemd160-hash-of-a-file
https://msdn.microsoft.com/en-us/library/system.security.cryptography.sha256cryptoserviceprovider(v=vs.110).aspx
https://msdn.microsoft.com/en-us/library/system.security.cryptography.md5cryptoserviceprovider(v=vs.110).aspx
https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/get-filehash
https://msdn.microsoft.com/en-us/library/system.security.cryptography.mactripledes(v=vs.110).aspx
https://msdn.microsoft.com/en-us/library/system.security.cryptography.ripemd160(v=vs.110).aspx
https://msdn.microsoft.com/en-us/library/system.security.cryptography(v=vs.110).aspx
https://msdn.microsoft.com/en-us/library/system.io.path_methods(v=vs.110).aspx
http://go.microsoft.com/fwlink/?LinkID=113418
http://stackoverflow.com/questions/21252824/how-do-i-get-powershell-4-cmdlets-such-as-test-netconnection-to-work-on-windows
http://windowsitpro.com/scripting/calculate-md5-and-sha1-file-hashes-using-powershell
https://gist.github.com/quentinproust/8d3bd11562a12446644f
http://poshcode.org/2154

#>
