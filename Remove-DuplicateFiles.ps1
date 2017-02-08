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
    [Alias("Combine","Compare")]
    [switch]$Global,
    [switch]$WhatIf,
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
    $all_folders = @()
    $duplicate_files = @()
    $skipped_path_names = @()
    $number_of_paths = $Path.Count
    $num_invalid_paths = 0



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
        $skip_text = "Couldn't find -Output folder '$Output'."
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
                Write-Verbose "Please consider checking that the '-Path' variable value of '$path_candidate' was typed correctly and that it is a valid file system path, which points to a directory. If the path name includes space characters, please enclose the path name in quotation marks (single or double)." -verbose
                $empty_line | Out-String
                $skip_text = "Skipping '$path_candidate' from the folders to be processed."
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
                                } # Else (If $available_folders)

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
                                $skipped_path_names += $item
                            } # ForEach $item
                        } # Else (If $unavailable_folders)
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

    ForEach ($folder_candidate in $unique_folders) {
            # Source: http://go.microsoft.com/fwlink/?LinkID=113418
            If ((Test-Path $folder_candidate -PathType Container) -eq $false) {
                # Skip the item ($folder_candidate) if it is not a folder (return to top of the program loop (ForEach $folder_candidate)
                Continue
            } Else {
                $all_folders += $folder_candidate
            } # Else (If Test-Path $folder_candidate)
    } # ForEach ($folder_candidate)


    If ($Global) {

            # Find the duplicate files (including the original file) in one go from all the eligible folders
            If (($PSVersionTable.PSVersion).Major -ge 4) {
                # Requires PowerShell version 4.0
                # Source: https://gist.github.com/quentinproust/8d3bd11562a12446644f
                # Source: https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/get-filehash
                $list = dir $all_folders -Force | Get-FileHash -Algorithm SHA256 -ErrorAction SilentlyContinue | Group-Object -Property Hash | Where-Object {( $_.Count -gt 1 )}
            } Else {
                # Requires PowerShell version 2 (and .NET Framework v3.5)
                # Credit: Lee Holmes: "Windows PowerShell Cookbook (O'Reilly)" (Get-FileHash script) http://www.leeholmes.com/guide
                $list = dir $all_folders -Force | Check-FileHash -Algorithm SHA256 | Group-Object -Property Hash | Where-Object {( $_.Count -gt 1 )}
            } # Else (If $PSVersionTable.PSVersion)

            # Enumerate the duplicate entities (excluding the original file)
            If ($list.Count -gt 1) {
                $duplicate_files += $list | ForEach-Object { $_ | select -ExpandProperty Group | select -ExpandProperty Path | select -Last ($_.Count -1) }
            } Else {
                $continue = $true
            } # Else (If $list.Count)

    } Else {

            ForEach ($folder in $all_folders) {

                # Find the duplicate files (including the original file) on 'per folder' basis
                If (($PSVersionTable.PSVersion).Major -ge 4) {
                    # Requires PowerShell version 4.0
                    # Source: https://gist.github.com/quentinproust/8d3bd11562a12446644f
                    # Source: https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/get-filehash
                    $list = dir "$folder" -Force | Get-FileHash -Algorithm SHA256 -ErrorAction SilentlyContinue | Group-Object -Property Hash | Where-Object {( $_.Count -gt 1 )}
                } Else {
                    # Requires PowerShell version 2 (and .NET Framework v3.5)
                    # Credit: Lee Holmes: "Windows PowerShell Cookbook (O'Reilly)" (Get-FileHash script) http://www.leeholmes.com/guide
                    $list = dir "$folder" -Force | Check-FileHash -Algorithm SHA256 | Group-Object -Property Hash | Where-Object {( $_.Count -gt 1 )}
                } # Else (If $PSVersionTable.PSVersion)

                # Enumerate the duplicate entities (excluding the original file)
                If ($list.Count -gt 1) {
                    $duplicate_files += $list | ForEach-Object { $_ | select -ExpandProperty Group | select -ExpandProperty Path | select -Last ($_.Count -1) }
                } Else {
                    $continue = $true
                } # Else (If $list.Count)

            } # ForEach ($folder)
    } # Else (If $Global)


                    # Process each file
                    # Source: https://msdn.microsoft.com/en-us/library/system.io.path_methods(v=vs.110).aspx
                    $unique_files = $duplicate_files | select -Unique
                    ForEach ($file in $unique_files) {

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
                                                                } # Else (If $PSVersionTable.PSVersion)
                                    } # New-Object
                    } # ForEach ($file)
} # Process




End {
                # Do the background work for natural language
                If ($unique_folders.Count -gt 1) { $item_text = "folders" } Else { $item_text = "folder" }
                $empty_line | Out-String

                    # Write the operational stats in console
                    If (($invalid_path_was_found) -ne $true) {
                        $enumeration_went_succesfully = $true
                                If ($all_folders.Count -le 4) {
                                    $stats_text = "Total $($unique_folders.Count) $item_text processed at $($all_folders -join ', ')."
                                } Else {
                                    $stats_text = "Total $($unique_folders.Count) $item_text processed."
                                } # Else (If $all_folders.Count)
                        Write-Output $stats_text
                    } Else {

                        # Display the skipped path names and write the operational stats in console
                        $enumeration_went_succesfully = $false
                        $skipped.PSObject.TypeNames.Insert(0,"Skipped Path Names")
                        $skipped_selection = $skipped | Select-Object 'Skipped Paths','Size','Error' | Sort-Object 'Skipped Paths'
                        $skipped_selection | Format-Table -auto
                                If ($num_invalid_paths -gt 1) {
                                    If ($all_folders.Count -eq 0) {
                                        $stats_text = "There were $num_invalid_paths skipped paths. Didn't process any folders."
                                    } ElseIf ($all_folders.Count -le 4) {
                                        $stats_text = "Total $($unique_folders.Count) $item_text processed at $($all_folders -join ', '). There were $num_invalid_paths skipped paths."
                                    } Else {
                                        $stats_text = "Total $($unique_folders.Count) $item_text processed. There were $num_invalid_paths skipped paths."
                                    } # Else (If $all_folders.Count)
                                } Else {
                                    If ($all_folders.Count -eq 0) {
                                        $stats_text = "One path name was skipped. Didn't process any folders."
                                    } ElseIf ($all_folders.Count -le 4) {
                                        $stats_text = "Total $($unique_folders.Count) $item_text processed at $($all_folders -join ', '). One path name was skipped."
                                    } Else {
                                        $stats_text = "Total $($unique_folders.Count) $item_text processed. One path name was skipped."
                                    } # Else (If $all_folders.Count)
                                } # Else (If $num_invalid_paths)
                        Write-Output $stats_text
                    } # Else (If $invalid_path_was_found)


    If ($results.Count -ge 1) {


        # Remove the duplicate files
        $empty_line | Out-String
        $deleted_files = $results | Select-Object -ExpandProperty 'Full Path'
        Remove-Item $deleted_files -Force -WhatIf:$WhatIf


        # Test if the files were removed
        If ((Test-Path $duplicate_files) -eq $true) {
                        If ($WhatIf) {
                            $empty_line | Out-String
                            "Exit Code 1: A simulation run (the -WhatIf parameter was used), didn't touch any files."
                            Return $empty_line
                        } Else {
                            "Exit Code 2: Something went wrong with the deletion procedure."
                            Return $empty_line
                        } # Else (If $WhatIf)
        } Else {
                # Write the header in console
                $deleted_files.PSObject.TypeNames.Insert(0,"Duplicate Files")
                $results.PSObject.TypeNames.Insert(0,"Duplicate Files")
                $results_selection = $results | select "File","Full Path","SHA256"
                        If ($deleted_files.Count -gt 1) {
                            $header = "Duplicate files that were deleted"
                            $coline = "---------------------------------"
                            Write-Output $header
                            $coline | Out-String
                            $written_data = $unique_files
                        } ElseIf ($deleted_files.Count -eq 1) {
                            $header = "The following duplicate file was deleted"
                            $coline = "----------------------------------------"
                            Write-Output $header
                            $coline | Out-String
                            $written_data = $unique_files.ToString()
                        } Else {
                                $continue = $true
                        } # Else (If $deleted_files.Count -gt 1)


                # Write the results in console
                Write-Output $written_data
                Write-Output $results_selection | Format-List


                # Write info about the removed duplicate files to a text file (located at the current temp-folder or the location is defined with the -Output parameter)
                $header_txt = "Deleted Files"
                $separator  = "-------------"

                        If ((Test-Path $txt_file) -eq $false) {
                            ($results_selection | Format-List) | Out-File "$txt_file" -Encoding UTF8 -Force
                            $results_list = Get-Content $txt_file
                            $empty_line  | Out-File "$txt_file" -Encoding UTF8 -Force
                            Add-Content -Path "$txt_file" -Value "$header_txt`r`n$separator`r`n$empty_line`r`n$empty_line" -Encoding UTF8
                            Add-Content -Path "$txt_file" -Value $written_data -Encoding UTF8
                            Add-Content -Path "$txt_file" -Value $results_list -Encoding UTF8
                            Add-Content -Path "$txt_file" -Value "Date: $(Get-Date -Format g)"
                        } Else {
                            $results_list = ($results_selection | Format-List)
                            $pre_existing_content = Get-Content $txt_file
                            ($pre_existing_content + $empty_line + $empty_line + $separator + $empty_line + $empty_line + $written_data + $results_list) | Out-File "$txt_file" -Encoding UTF8 -Force
                            Add-Content -Path "$txt_file" -Value "Date: $(Get-Date -Format g)"
                        } # Else (If Test-Path $txt_file)

                # Sound the bell if set to do so with the -Audio parameter (ASCII character 7)
                If ( -not $Audio ) {
                        $continue = $true
                } Else {
                        [char]7
                } # Else
        } # Else (If Test-Path $duplicate_files)
    } Else {
        If ($all_folders.Count -ge 1) {
            $empty_line | Out-String
            $exit_text = "Didn't detect any duplicate files."
            Write-Output $exit_text
            $empty_line | Out-String
        } Else {
            $empty_line | Out-String
        } # Else (If $all_folders.Count)
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
the -Path parameter. The files of a folder are analysed with the inbuilt
Get-FileHash cmdlet in machines that have PowerShell version 4 or later installed,
and in machines that are running PowerShell version 2 or 3 the .NET Framework
commands (and a function called Check-FileHash, which is based on Lee Holmes'
Get-FileHash script in "Windows PowerShell Cookbook (O'Reilly)"
(http://www.leeholmes.com/guide)) are invoked for determining whether or not any
duplicate files exist in a particular folder.

Multiple paths may be entered to the -Path parameter (separated with a comma) and
sub-directories may be included to the list of folders to process by adding the
-Recurse parameter to the launching command. By default the removal of files in
Remove-DuplicateFiles is done on 'per directory' -basis, where each individual
folder is treated as its own separate entity, and the duplicate files are searched
and removed within one particular folder realm at a time, so for example if a file
exists twice in Folder A and also once in Folder B, only the second instance of the
file in Folder A would be deleted by Remove-DuplicateFiles by default. To make
Remove-DuplicateFiles delete also the duplicate file that is in Folder B (in the
previous example), a parameter called -Global may be added to the launching command,
which makes Remove-DuplicateFiles behave more holistically and analyse all the items
in every found directory in one go and compare each found file with each other.

If deletions are made, a log-file (deleted_files.txt by default) is created to
$env:temp, which points to the current temporary file location and is set in the
system (- for more information about $env:temp, please see the Notes section). The
filename of the log-file can be set with the -FileName parameter (a filename with a
.txt ending is recommended) and the default output destination folder may be changed
with the -Output parameter. During the possibly invoked log-file creation procedure
Remove-DuplicateFiles tries to preserve any pre-existing content rather than
overwrite the specified file, so if the -FileName parameter points to an existing
file, new log-info data is appended to the end of that file.

To invoke a simulation run, where no files would be deleted in any circumstances,
a parameter -WhatIf may be added to the launching command. If the -Audio parameter
has been used, an audible beep would be emitted after Remove-DuplicateFiles has
deleted one or more files. Please note that if any of the parameter values (after
the parameter name itself) includes space characters, the value should be enclosed
in quotation marks (single or double) so that PowerShell can interpret the command
correctly.

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
folders to be processed is toggled with the -Recurse parameter. Furthermore, the
parameter -Global toggles whether the contents of found folders are compared
with each other or not.

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
processed by Remove-DuplicateFiles. If the -Recurse parameter is not used, the only
folders that are processed are those which have been defined with the -Path
parameter.

.PARAMETER Global
with aliases -Combine and -Compare. If the -Global parameter is added to the command
launching Remove-DuplicateFiles, the contents of different folders are combined and
compared with each other, so for example if a file exists twice in Folder A and also
once in Folder B, the second instance in folder A and the file in Folder B would be
deleted by Remove-DuplicateFiles (only one instance of a file would be universally
kept). Before trying to remove any files from multiple locations with the -Global
parameter in Remove-DuplicateFiles, it is recommended to use both the -WhatIf
parameter and the -Global parameter in the command launching Remove-DuplicateFiles
in order to make sure, that the correct original file in the correct directory
would be left untouched by Remove-DuplicateFiles.

If the -Global parameter is not used, the removal of files is done on 'per
directory' -basis and the contents of different folders are not compared with each
other, so those duplicate files, which exist alone in their own folder will be
preserved (as per default one instance of a file in each folder) even after
Remove-DuplicateFiles has been run (each folder is regarded as an separate entity
or realm).

.PARAMETER WhatIf
The parameter -WhatIf toggles whether the deletion of files is actually done or not.
By adding the -WhatIf parameter to the launching command only a simulation run is
performed. When the -WhatIf parameter is added to the command launching
Remove-DuplicateFiles, a -WhatIf parameter is also added to the underlying
Remove-Item cmdlet that is deleting the files in Remove-DuplicateFiles. In such
case and if duplicate file(s) was/were detected by Remove-DuplicateFiles, a list of
files that would be deleted by Remove-DuplicateFiles is displayed in console
("What if:"). Since no real deletions were be made, the script will return an
"Exit Code 1" (A simulation run: the -WhatIf parameter was used).

In case there were no duplicate files to begin with, the result is the same,
whether the -WhatIf parameter was used or not. Before trying to remove any files
from multiple locations with the -Global parameter in Remove-DuplicateFiles, it is
recommended to use both the -WhatIf parameter and the -Global parameter in the
command launching Remove-DuplicateFiles in order to make sure, that the correct
original file in the correct directory would be left untouched by
Remove-DuplicateFiles.

.PARAMETER Audio
If this parameter is used in the remove duplicate files command, an audible beep
will occur, if any deletions are made by Remove-DuplicateFiles (and if the system
is not set to mute).

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
    Version:            1.1

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
./Remove-DuplicateFiles -Path "E:\chiore", "C:\dc01" -Output "C:\Scripts" -Global

Run the script and remove all duplicate files from the first level of "E:\chiore"
and "C:\dc01" (i.e. those duplicate files, which would be listed by combining the
results of "dir E:\chiore" and "dir E:\dc01" commands), and if any deletions are
made, save the log-file to C:\Scripts with the default filename (deleted_files.txt).
If a file exists in "E:\chiore" and also in "C:\dc01" (i.e. the other instance is a
duplicate file), one instance would be preserved and the other would be deleted by
Remove-DuplicateFiles. The word -Path and the quotation marks could be omitted in
this example, too.

.EXAMPLE
./Remove-DuplicateFiles -Path "C:\Users\Dropbox" -Recurse -WhatIf

Because the -WhatIf parameter was used, only a simulation run occurs, so no files
would be deleted in any circumstances. The script will look for duplicate files from
C:\Users\Dropbox and will add all sub-directories of the sub-directories of the
sub-directories and their sub-directories as well to the list of folders to process
(the search for other folders to process is done recursively). Each of the found
folders is searched separately (or individually) for duplicate files (so if a file
exists twice in Folder A and also once in Folder B, only the second instance of the
file in Folder A would be added to list of files to be deleted).

If duplicate files aren't found (when looked at every folder separately and the
contents of each folder are not compared with each other, since the -Global
parameter was not used), the result would be identical regardless whether the
-WhatIf parameter was used or not. If, however, duplicate files were indeed found,
only an indication of what the script would delete ("What if:") is displayed.

The Path variable value is case-insensitive (as is most of the PowerShell), and
since the path name doesn't contain any space characters, it doesn't need to be
enveloped with quotation marks. Actually the -Path parameter may be left out from
the command, too, since, for example,

    ./Remove-DuplicateFiles c:\users\dROPBOx -Recurse -WhatIf

is the exact same command in nature.

.EXAMPLE
.\Remove-DuplicateFiles.ps1 -From C:\dc01 -ReportPath C:\Scripts -File log.txt -Recurse -Combine -Audio

Run the script and delete all the duplicate files found in C:\dc01 and in every
subfolder under C:\dc01 combined. The duplicate files are searched in one go from
all the found folders and the contents of all folders are compared with each other.

If any deletions were made, the log-file would be saved to C:\Scripts with the
filename log.txt and an audible beep would occur. This command will work, because
-From is an alias of -Path and -ReportPath is an alias of -Output, -File is an
alias of -FileName and -Combine is an alias of -Glogal. Furthermore, since the path
names or the file neame don't contain any space characters, they don't need to be
enclosed in quotation marks.

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
