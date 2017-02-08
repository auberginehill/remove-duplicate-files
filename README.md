<!-- Visual Studio Code: For a more comfortable reading experience, use the key combination Ctrl + Shift + V
     Visual Studio Code: To crop the tailing end space characters out, please use the key combination Ctrl + A Ctrl + K Ctrl + X (Formerly Ctrl + Shift + X)
     Visual Studio Code: To improve the formatting of HTML code, press Shift + Alt + F and the selected area will be reformatted in a html file.
     Visual Studio Code shortcuts: http://code.visualstudio.com/docs/customization/keybindings (or https://aka.ms/vscodekeybindings)
     Visual Studio Code shortcut PDF (Windows): https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf


  _____                                      _____              _ _           _       ______ _ _
 |  __ \                                    |  __ \            | (_)         | |     |  ____(_) |
 | |__) |___ _ __ ___   _____   _____ ______| |  | |_   _ _ __ | |_  ___ __ _| |_ ___| |__   _| | ___  ___
 |  _  // _ \ '_ ` _ \ / _ \ \ / / _ \______| |  | | | | | '_ \| | |/ __/ _` | __/ _ \  __| | | |/ _ \/ __|
 | | \ \  __/ | | | | | (_) \ V /  __/      | |__| | |_| | |_) | | | (_| (_| | ||  __/ |    | | |  __/\__ \
 |_|  \_\___|_| |_| |_|\___/ \_/ \___|      |_____/ \__,_| .__/|_|_|\___\__,_|\__\___|_|    |_|_|\___||___/
                                                         | |
                                                         |_|                                                                 -->


## Remove-DuplicateFiles.ps1

<table>
   <tr>
      <td style="padding:6px"><strong>OS:</strong></td>
      <td style="padding:6px">Windows</td>
   </tr>
   <tr>
      <td style="padding:6px"><strong>Type:</strong></td>
      <td style="padding:6px">A Windows PowerShell script</td>
   </tr>
   <tr>
      <td style="padding:6px"><strong>Language:</strong></td>
      <td style="padding:6px">Windows PowerShell</td>
   </tr>
   <tr>
      <td style="padding:6px"><strong>Description:</strong></td>
      <td style="padding:6px">Remove-DuplicateFiles searches for duplicate files from a directory specified with the <code>-Path</code> parameter. The files of a folder are analysed with the inbuilt <code>Get-FileHash</code> cmdlet in machines that have PowerShell version 4 or later installed, and in machines that are running PowerShell version 2 or 3 the .NET Framework commands (and a function called <dfn>Check-FileHash</dfn>, which is based on <strong>Lee Holmes</strong>' <dfn>Get-FileHash</dfn> <a href="http://poshcode.org/2154">script</a> in "<a href="http://www.leeholmes.com/guide">Windows PowerShell Cookbook (O'Reilly)</a>") are invoked for determining whether or not any duplicate files exist in a particular folder.
      <br />
      <br />Multiple paths may be entered to the <code>-Path</code> parameter (separated with a comma) and sub-directories may be included to the list of folders to process by adding the <code>-Recurse</code> parameter to the launching command. By default the removal of files in Remove-DuplicateFiles is done on 'per directory' -basis, where each individual folder is treated as its own separate entity, and the duplicate files are searched and removed within one particular folder realm at a time, so for example if a file exists twice in Folder A and also once in Folder B, only the second instance of the file in Folder A would be deleted by Remove-DuplicateFiles by default. To make Remove-DuplicateFiles delete also the duplicate file that is in Folder B (in the previous example), a parameter called <code>-Global</code> may be added to the launching command, which makes Remove-DuplicateFiles behave more holistically and analyse all the items in every found directory in one go and compare each found file with each other.
      <br />
      <br />If deletions are made, a log-file (<code>deleted_files.txt</code> by default) is created to <code>$env:temp</code>, which points to the current temporary file location and is set in the system (– for more information about <code>$env:temp</code>, please see the Notes section). The filename of the log-file can be set with the <code>-FileName</code> parameter (a filename with a <code>.txt</code> ending is recommended) and the default output destination folder may be changed with the <code>-Output</code> parameter. During the possibly invoked log-file creation procedure Remove-DuplicateFiles tries to preserve any pre-existing content rather than overwrite the specified file, so if the <code>-FileName</code> parameter points to an existing file, new log-info data is appended to the end of that file.
      <br />
      <br />To invoke a simulation run, where no files would be deleted in any circumstances, a parameter <code>-WhatIf</code> may be added to the launching command. If the <code>-Audio</code> parameter has been used, an audible beep would be emitted after Remove-DuplicateFiles has deleted one or more files. Please note that if any of the parameter values (after the parameter name itself) includes space characters, the value should be enclosed in quotation marks (single or double) so that PowerShell can interpret the command correctly.</td>
   </tr>
   <tr>
      <td style="padding:6px"><strong>Homepage:</strong></td>
      <td style="padding:6px"><a href="https://github.com/auberginehill/remove-duplicate-files">https://github.com/auberginehill/remove-duplicate-files</a>
      <br />Short URL: <a href="http://tinyurl.com/jv4jlbe">http://tinyurl.com/jv4jlbe</a></td>
   </tr>
   <tr>
      <td style="padding:6px"><strong>Version:</strong></td>
      <td style="padding:6px">1.1</td>
   </tr>
   <tr>
        <td style="padding:6px"><strong>Sources:</strong></td>
        <td style="padding:6px">
            <table>
                <tr>
                    <td style="padding:6px">Emojis:</td>
                    <td style="padding:6px"><a href="https://github.com/auberginehill/emoji-table">Emoji Table</a></td>
                </tr>
                <tr>
                    <td style="padding:6px">Mekac:</td>
                    <td style="padding:6px"><a href="https://social.technet.microsoft.com/Forums/en-US/4d78bba6-084a-4a41-8d54-6dde2408535f/get-folder-where-access-is-denied?forum=winserverpowershell">Get folder where Access is denied</a></td>
                </tr>
                <tr>
                    <td style="padding:6px">Mike F Robbins:</td>
                    <td style="padding:6px"><a href="http://mikefrobbins.com/2015/03/31/powershell-advanced-functions-can-we-build-them-better-with-parameter-validation-yes-we-can/">PowerShell Advanced Functions: Can we build them better?</a></td>
                </tr>
                <tr>
                    <td style="padding:6px">Lee Holmes:</td>
                    <td style="padding:6px"><a href="http://www.leeholmes.com/guide">Windows PowerShell Cookbook (O'Reilly)</a>: Get-FileHash <a href="http://poshcode.org/2154">script</a></td>
                </tr>
                <tr>
                    <td style="padding:6px">Gisli:</td>
                    <td style="padding:6px"><a href="http://stackoverflow.com/questions/8711564/unable-to-read-an-open-file-with-binary-reader">Unable to read an open file with binary reader</a></td>
                </tr>
                <tr>
                    <td style="padding:6px">Twon of An:</td>
                    <td style="padding:6px"><a href="https://community.spiceworks.com/scripts/show/2263-get-the-sha1-sha256-sha384-sha512-md5-or-ripemd160-hash-of-a-file">Get the SHA1,SHA256,SHA384,SHA512,MD5 or RIPEMD160 hash of a file</a></td>
                </tr>
            </table>
        </td>
   </tr>
   <tr>
      <td style="padding:6px"><strong>Downloads:</strong></td>
      <td style="padding:6px">For instance <a href="https://raw.githubusercontent.com/auberginehill/remove-duplicate-files/master/Remove-DuplicateFiles.ps1">Remove-DuplicateFiles.ps1</a>. Or <a href="https://github.com/auberginehill/remove-duplicate-files/archive/master.zip">everything as a .zip-file</a>.</td>
   </tr>
</table>




### Screenshot

<ul><ul><ul>
<img class="screenshot" title="screenshot" alt="screenshot" height="80%" width="80%" src="https://raw.githubusercontent.com/auberginehill/remove-duplicate-files/master/Remove-DuplicateFiles.png">
</ul></ul></ul>




### Parameters

<table>
    <tr>
        <th>:triangular_ruler:</th>
        <td style="padding:6px">
            <ul>
                <li>
                    <h5>Parameter <code>-Path</code></h5>
                    <p>with aliases <code>-Start</code>, <code>-Begin</code>, <code>-Folder</code>, and <code>-From</code>. The <code>-Path</code> parameter determines the starting point of the duplicate file analysation. The <code>-Path</code> parameter also accepts a collection of path names (separated by a comma). It's not mandatory to write <code>-Path</code> in the remove duplicate files command to invoke the <code>-Path</code> parameter, as is shown in the Examples below, since Remove-DuplicateFiles is trying to decipher the inputted queries as good as it is machinely possible within a 50 KB size limit.</p>
                    <p>The paths should be valid file system paths to a directory (a full path name of a directory (i.e. folder path such as <code>C:\Windows</code>)). In case the path name includes space characters, please enclose the path name in quotation marks (single or double). If a collection of path names is defined for the <code>-Path</code> parameter, please separate the individual path names with a comma. The <code>-Path</code> parameter also takes an array of strings for paths and objects could be piped to this parameter, too. If no path is defined in the command launching Remove-DuplicateFiles the user will be prompted to enter a <code>-Path</code> value. Whether or not the subdirectories are added to the list of folders to be processed is toggled with the <code>-Recurse</code> parameter. Furthermore, the parameter <code>-Global</code> toggles whether the contents of found folders are compared with each other or not.</p>
                </li>
            </ul>
        </td>
    </tr>
    <tr>
        <th></th>
        <td style="padding:6px">
            <ul>
                <p>
                    <li>
                        <h5>Parameter <code>-Output</code></h5>
                        <p>with an alias <code>-ReportPath</code>. Specifies where the log-file (<code>deleted_files.txt</code> by default), which is created or updated when deletions are made, is to be saved. The default save location is <code>$env:temp</code>, which points to the current temporary file location, which is set in the system. The default <code>-Output</code> save location is defined at line 16 with the <code>$Output</code> variable. In case the path name includes space characters, please enclose the path name in quotation marks (single or double). For usage, please see the Examples below and for more information about <code>$env:temp</code>, please see the Notes section below.</p>
                    </li>
                </p>
                <p>
                    <li>
                        <h5>Parameter <code>-FileName</code></h5>
                        <p>with an alias <code>-File</code>. The filename of the log-file can be set with the <code>-FileName</code> parameter (a filename with a <code>.txt</code> ending is recommended, the default filename is <code>deleted_files.txt</code>). During the possibly invoked log-file creation procedure Remove-DuplicateFiles tries to preserve any pre-existing content rather than overwrite the specified file, so if the <code>-FileName</code> parameter points to an existing file, new log-info data is appended to the end of that file. If the filename includes space characters, please enclose the filename in quotation marks (single or double).</p>
                    </li>
                </p>
                <p>
                    <li>
                        <h5>Parameter <code>-Recurse</code></h5>
                        <p>If the <code>-Recurse</code> parameter is added to the command launching Remove-DuplicateFiles, also each and every sub-folder in any level, no matter how deep in the directory structure or behind how many sub-folders, is added to the list of folders to be processed by Remove-DuplicateFiles. If the <code>-Recurse</code> parameter is not used, the only folders that are processed are those which have been defined with the <code>-Path</code> parameter.</p>
                    </li>
                </p>
                <p>
                    <li>
                        <h5>Parameter <code>-Global</code></h5>
                        <p>with aliases <code>-Combine</code> and <code>-Compare</code>. If the <code>-Global</code> parameter is added to the command launching Remove-DuplicateFiles, the contents of different folders are combined and compared with each other, so for example if a file exists twice in Folder A and also once in Folder B, the second instance in folder A and the file in Folder B would be deleted by Remove-DuplicateFiles (only one instance of a file would be universally kept). Before trying to remove files from multiple locations with the <code>-Global</code> parameter in Remove-DuplicateFiles, it is recommended to use both the <code>-WhatIf</code> parameter and the <code>-Global</code> parameter in the command launching Remove-DuplicateFiles in order to make sure, that the correct original file in the correct directory would be left untouched by Remove-DuplicateFiles.</p>
                        <p>If the <code>-Global</code> parameter is not used, the removal of files is done on 'per directory' -basis and the contents of different folders are not compared with each other, so those duplicate files, which exist alone in their own folder will be preserved (as per default one instance of a file in each folder) even after Remove-DuplicateFiles has been run (each folder is regarded as an separate entity or realm).</p>
                    </li>
                </p>
                <p>
                    <li>
                        <h5>Parameter <code>-WhatIf</code></h5>
                        <p>The parameter <code>-WhatIf</code> toggles whether the deletion of files is actually done or not. By adding the <code>-WhatIf</code> parameter to the launching command only a simulation run is performed. When the <code>-WhatIf</code> parameter is added to the command launching Remove-DuplicateFiles, a <code>-WhatIf</code> parameter is also added to the underlying <code>Remove-Item</code> cmdlet that is deleting the files in Remove-DuplicateFiles. In such case and if duplicate file(s) was/were detected by Remove-DuplicateFiles, a list of files that would be deleted by Remove-DuplicateFiles is displayed in console ("What if:"). Since no real deletions aren't made, the script will return an "Exit Code 1" (A simulation run: the <code>-WhatIf</code> parameter was used).</p>
                        <p>In case there were no duplicate files to begin with, the result is the same, whether the <code>-WhatIf</code> parameter was used or not. Before trying to remove files from multiple locations with the <code>-Global</code> parameter in Remove-DuplicateFiles, it is recommended to use both the <code>-WhatIf</code> parameter and the <code>-Global</code> parameter in the command launching Remove-DuplicateFiles in order to make sure, that the correct original file in the correct directory would be left untouched by Remove-DuplicateFiles.</p>
                    </li>
                </p>
                <p>
                    <li>
                        <h5>Parameter <code>-Audio</code></h5>
                        <p>If this parameter is used in the remove duplicate files command, an audible beep will occur, if any deletions are made by Remove-DuplicateFiles (and if the system is not set to mute).</p>
                    </li>
                </p>
            </ul>
        </td>
    </tr>
</table>




### Outputs

<table>
    <tr>
        <th>:arrow_right:</th>
        <td style="padding:6px">
            <ul>
                <li>Deletes duplicate files in one or multiple folders.</li>
            </ul>
        </td>
    </tr>
    <tr>
        <th></th>
        <td style="padding:6px">
            <ul>
                <p>
                    <li>Displays results about deleting duplicate files in console, and if any deletions were made, writes or updates a logfile (<code>deleted_files.txt</code>) at <code>$env:temp</code>. The filename of the log-file can be set with the <code>-FileName</code> parameter (a filename with a <code>.txt</code> ending is recommended) and the default output destination folder may be changed with the <code>-Output</code> parameter.</li>
                </p>
                <p>
                    <li>Default values (the log-file creation/updating procedure only occurs if deletion(s) is/are made by Remove-DuplicateFiles):</li>
                </p>
                <ol>
                    <p>
                        <table>
                            <tr>
                                <td style="padding:6px"><strong>Path</strong></td>
                                <td style="padding:6px"><strong>Type</strong></td>
                                <td style="padding:6px"><strong>Name</strong></td>
                            </tr>
                            <tr>
                                <td style="padding:6px"><code>$env:temp\deleted_files.txt</code></td>
                                <td style="padding:6px">TXT-file</td>
                                <td style="padding:6px"><code>deleted_files.txt</code></td>
                            </tr>
                        </table>
                    </p>
                </ol>
            </ul>
        </td>
    </tr>
</table>




### Notes

<table>
    <tr>
        <th>:warning:</th>
        <td style="padding:6px">
            <ul>
                <li>Please note that all the parameters can be used in one remove duplicate files command and that each of the parameters can be "tab completed" before typing them fully (by pressing the <code>[tab]</code> key).</li>
            </ul>
        </td>
    </tr>
    <tr>
        <th></th>
        <td style="padding:6px">
            <ul>
                <p>
                    <li>Please also note that the possibly generated log-file is created in a directory, which is end-user settable in each remove duplicate files command with the <code>-Output</code> parameter. The default save location is defined with the <code>$Output</code> variable (at line 16). The <code>$env:temp</code> variable points to the current temp folder. The default value of the <code>$env:temp</code> variable is <code>C:\Users\&lt;username&gt;\AppData\Local\Temp</code> (i.e. each user account has their own separate temp folder at path <code>%USERPROFILE%\AppData\Local\Temp</code>). To see the current temp path, for instance a command
                    <br />
                    <br /><code>[System.IO.Path]::GetTempPath()</code>
                    <br />
                    <br />may be used at the PowerShell prompt window <code>[PS&gt;]</code>. To change the temp folder for instance to <code>C:\Temp</code>, please, for example, follow the instructions at <a href="http://www.eightforums.com/tutorials/23500-temporary-files-folder-change-location-windows.html">Temporary Files Folder - Change Location in Windows</a>, which in essence are something along the lines:
                        <ol>
                           <li>Right click on Computer and click on Properties (or select Start → Control Panel → System). In the resulting window with the basic information about the computer...</li>
                           <li>Click on Advanced system settings on the left panel and select Advanced tab on the resulting pop-up window.</li>
                           <li>Click on the button near the bottom labeled Environment Variables.</li>
                           <li>In the topmost section labeled User variables both TMP and TEMP may be seen. Each different login account is assigned its own temporary locations. These values can be changed by double clicking a value or by highlighting a value and selecting Edit. The specified path will be used by Windows and many other programs for temporary files. It's advisable to set the same value (a directory path) for both TMP and TEMP.</li>
                           <li>Any running programs need to be restarted for the new values to take effect. In fact, probably also Windows itself needs to be restarted for it to begin using the new values for its own temporary files.</li>
                        </ol>
                    </li>
                </p>
            </ul>
        </td>
    </tr>
</table>




### Examples

<table>
    <tr>
        <th>:book:</th>
        <td style="padding:6px">To open this code in Windows PowerShell, for instance:</td>
   </tr>
   <tr>
        <th></th>
        <td style="padding:6px">
            <ol>
                <p>
                    <li><code>./Remove-DuplicateFiles -Path "E:\chiore"</code><br />
                    Run the script. Please notice to insert <code>./</code> or <code>.\</code> before the script name. Removes duplicate files from the "<code>E:\chiore</code>" directory and saves the generated log-file at the default location (<code>$env:temp</code>), if any deletions were made. Regardless of how many subfolders there are or are not in "<code>E:\chiore</code>" the duplicate files are analysed at the first level only (i.e. the base for the file analysation is non-recursive, similar to a common command "<code>dir</code>", for example). During the possibly invoked log-file creation procedure Remove-DuplicateFiles tries to preserve any pre-existing content rather than overwrite the file, so if the default log-file (<code>deleted_files.txt</code>) already exists, new log-info data is appended to the end of that file. Please note, that <code>-Path</code> and the quotation marks can be omitted in this example, because
                    <br />
                    <br /><code>./Remove-DuplicateFiles E:\chiore</code>
                    <br />
                    <br />will result in the exact same outcome, since the path name is accepted as a first defined value automatically and since the path name doesn't contain any space characters.</li>
                </p>
                <p>
                    <li><code>help ./Remove-DuplicateFiles -Full</code><br />
                    Display the help file.</li>
                </p>
                <p>
                    <li><code>./Remove-DuplicateFiles -Path "E:\chiore", "C:\dc01" -Output "C:\Scripts" -Global</code><br />
                    Run the script and remove all duplicate files from the first level of "<code>E:\chiore</code>" and "<code>C:\dc01</code>" (i.e. those duplicate files, which would be listed by combining the results of "<code>dir E:\chiore</code>" and "<code>dir E:\dc01</code>" commands), and if any deletions are made, save the log-file to <code>C:\Scripts</code> with the default filename (<code>deleted_files.txt</code>). If a file exists in "<code>E:\chiore</code>" and also in "<code>C:\dc01</code>" (i.e. the other instance is a duplicate file), one instance would be preserved and the other would be deleted by Remove-DuplicateFiles. The word -Path and the quotation marks could be omitted in this example, too. </li>
                </p>
                <p>
                    <li><code>./Remove-DuplicateFiles -Path "C:\Users\Dropbox" -Recurse -WhatIf</code><br />
                    Because the <code>-WhatIf</code> parameter was used, only a simulation run occurs, so no files would be deleted in any circumstances. The script will look for duplicate files from <code>C:\Users\Dropbox</code> and will add all sub-directories of the sub-directories of the sub-directories and their sub-directories as well to the list of folders to process (the search for other folders to process is done recursively). Each of the found folders is searched separately (or individually) for duplicate files (so if a file exists twice in Folder A and also once in Folder B, only the second instance of the file in Folder A would be added to list of files to be deleted).
                    <br />
                    <br />If duplicate files aren't found (when looked at every folder separately and the contents of each folder are not compared with each other, since the <code>-Global</code> parameter was not used), the result would be identical regardless whether the <code>-WhatIf</code> parameter was used or not. If, however, duplicate files were indeed found, only an indication of what the script would delete ("What if:") is displayed.
                    <br />
                    <br />The Path variable value is case-insensitive (as is most of the PowerShell), and since the path name doesn't contain any space characters, it doesn't need to be enveloped with quotation marks. Actually the <code>-Path</code> parameter may be left out from the command, too, since, for example,
                    <br />
                    <br /><code>./Remove-DuplicateFiles c:\users\dROPBOx -Recurse -WhatIf</code>
                    <br />
                    <br />is the exact same command in nature.</li>
                </p>
                <p>
                    <li><code>.\Remove-DuplicateFiles.ps1 -From C:\dc01 -ReportPath C:\Scripts -File log.txt -Recurse -Combine -Audio</code><br />
                    Run the script and delete all the duplicate files found in <code>C:\dc01</code> and in every subfolder under <code>C:\dc01</code> combined. The duplicate files are searched in one go from all the found folders and the contents of all folders are compared with each other.
                    <br />
                    <br />If any deletions were made, the log-file would be saved to <code>C:\Scripts</code> with the filename <code>log.txt</code> and an audible beep would occur. This command will work, because <code>-From</code> is an alias of <code>-Path</code> and <code>-ReportPath</code> is an alias of <code>-Output</code>, <code>-File</code> is an alias of <code>-FileName</code> and <code>-Combine</code> is an alias of <code>-Glogal</code>. Furthermore, since the path names or the file name don't contain any space characters, they don't need to be enclosed in quotation marks.</li>
                </p>
                <p>
                    <li><p><code>Set-ExecutionPolicy remotesigned</code><br />
                    This command is altering the Windows PowerShell rights to enable script execution for the default (LocalMachine) scope. Windows PowerShell has to be run with elevated rights (run as an administrator) to actually be able to change the script execution properties. The default value of the default (LocalMachine) scope is "<code>Set-ExecutionPolicy restricted</code>".</p>
                        <p>Parameters:
                                <ol>
                                    <table>
                                        <tr>
                                            <td style="padding:6px"><code>Restricted</code></td>
                                            <td style="padding:6px">Does not load configuration files or run scripts. Restricted is the default execution policy.</td>
                                        </tr>
                                        <tr>
                                            <td style="padding:6px"><code>AllSigned</code></td>
                                            <td style="padding:6px">Requires that all scripts and configuration files be signed by a trusted publisher, including scripts that you write on the local computer.</td>
                                        </tr>
                                        <tr>
                                            <td style="padding:6px"><code>RemoteSigned</code></td>
                                            <td style="padding:6px">Requires that all scripts and configuration files downloaded from the Internet be signed by a trusted publisher.</td>
                                        </tr>
                                        <tr>
                                            <td style="padding:6px"><code>Unrestricted</code></td>
                                            <td style="padding:6px">Loads all configuration files and runs all scripts. If you run an unsigned script that was downloaded from the Internet, you are prompted for permission before it runs.</td>
                                        </tr>
                                        <tr>
                                            <td style="padding:6px"><code>Bypass</code></td>
                                            <td style="padding:6px">Nothing is blocked and there are no warnings or prompts.</td>
                                        </tr>
                                        <tr>
                                            <td style="padding:6px"><code>Undefined</code></td>
                                            <td style="padding:6px">Removes the currently assigned execution policy from the current scope. This parameter will not remove an execution policy that is set in a Group Policy scope.</td>
                                        </tr>
                                    </table>
                                </ol>
                        </p>
                    <p>For more information, please type "<code>Get-ExecutionPolicy -List</code>", "<code>help Set-ExecutionPolicy -Full</code>", "<code>help about_Execution_Policies</code>" or visit <a href="https://technet.microsoft.com/en-us/library/hh849812.aspx">Set-ExecutionPolicy</a> or <a href="http://go.microsoft.com/fwlink/?LinkID=135170">about_Execution_Policies</a>.</p>
                    </li>
                </p>
                <p>
                    <li><code>New-Item -ItemType File -Path C:\Temp\Remove-DuplicateFiles.ps1</code><br />
                    Creates an empty ps1-file to the <code>C:\Temp</code> directory. The <code>New-Item</code> cmdlet has an inherent <code>-NoClobber</code> mode built into it, so that the procedure will halt, if overwriting (replacing the contents) of an existing file is about to happen. Overwriting a file with the <code>New-Item</code> cmdlet requires using the <code>Force</code>. If the path name and/or the filename includes space characters, please enclose the whole <code>-Path</code> parameter value in quotation marks (single or double):
                        <ol>
                            <br /><code>New-Item -ItemType File -Path "C:\Folder Name\Remove-DuplicateFiles.ps1"</code>
                        </ol>
                    <br />For more information, please type "<code>help New-Item -Full</code>".</li>
                </p>
            </ol>
        </td>
    </tr>
</table>




### Contributing

<p>Find a bug? Have a feature request? Here is how you can contribute to this project:</p>

 <table>
   <tr>
      <th><img class="emoji" title="contributing" alt="contributing" height="28" width="28" align="absmiddle" src="https://assets-cdn.github.com/images/icons/emoji/unicode/1f33f.png"></th>
      <td style="padding:6px"><strong>Bugs:</strong></td>
      <td style="padding:6px"><a href="https://github.com/auberginehill/remove-duplicate-files/issues">Submit bugs</a> and help us verify fixes.</td>
   </tr>
   <tr>
      <th rowspan="2"></th>
      <td style="padding:6px"><strong>Feature Requests:</strong></td>
      <td style="padding:6px">Feature request can be submitted by <a href="https://github.com/auberginehill/remove-duplicate-files/issues">creating an Issue</a>.</td>
   </tr>
   <tr>
      <td style="padding:6px"><strong>Edit Source Files:</strong></td>
      <td style="padding:6px"><a href="https://github.com/auberginehill/remove-duplicate-files/pulls">Submit pull requests</a> for bug fixes and features and discuss existing proposals.</td>
   </tr>
 </table>




### www

<table>
    <tr>
        <th><img class="emoji" title="www" alt="www" height="28" width="28" align="absmiddle" src="https://assets-cdn.github.com/images/icons/emoji/unicode/1f310.png"></th>
        <td style="padding:6px"><a href="https://github.com/auberginehill/remove-duplicate-files">Script Homepage</a></td>
    </tr>
    <tr>
        <th rowspan="22"></th>
        <td style="padding:6px">Mekac: <a href="https://social.technet.microsoft.com/Forums/en-US/4d78bba6-084a-4a41-8d54-6dde2408535f/get-folder-where-access-is-denied?forum=winserverpowershell">Get folder where Access is denied</a></td>
    </tr>
    <tr>
        <td style="padding:6px">Mike F Robbins: <a href="http://mikefrobbins.com/2015/03/31/powershell-advanced-functions-can-we-build-them-better-with-parameter-validation-yes-we-can/">PowerShell Advanced Functions: Can we build them better?</a></td>
    </tr>
    <tr>
        <td style="padding:6px">Lee Holmes: <a href="http://www.leeholmes.com/guide">Windows PowerShell Cookbook (O'Reilly)</a>: Get-FileHash <a href="http://poshcode.org/2154">script</a></td>
    </tr>
    <tr>
        <td style="padding:6px">Gisli: <a href="http://stackoverflow.com/questions/8711564/unable-to-read-an-open-file-with-binary-reader">Unable to read an open file with binary reader</a></td>
    </tr>
    <tr>
        <td style="padding:6px">Twon of An: <a href="https://community.spiceworks.com/scripts/show/2263-get-the-sha1-sha256-sha384-sha512-md5-or-ripemd160-hash-of-a-file">Get the SHA1,SHA256,SHA384,SHA512,MD5 or RIPEMD160 hash of a file</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://gist.github.com/nedarb/840f9f0c9a2e6014d38f">RemoveEmptyFolders.ps1</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://gist.github.com/Appius/d863ada643c2ee615db9">Remove all empty folders.ps1</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="http://www.brangle.com/wordpress/2009/08/append-text-to-a-file-using-add-content-in-powershell/">Append Text to a File Using Add-Content in PowerShell</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.core/about/about_functions_advanced_parameters">About Functions Advanced Parameters</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://msdn.microsoft.com/en-us/library/system.security.cryptography.sha256cryptoserviceprovider(v=vs.110).aspx">SHA256CryptoServiceProvider Class</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://msdn.microsoft.com/en-us/library/system.security.cryptography.md5cryptoserviceprovider(v=vs.110).aspx">MD5CryptoServiceProvider Class</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://msdn.microsoft.com/en-us/powershell/reference/5.1/microsoft.powershell.utility/get-filehash">Get-FileHash</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://msdn.microsoft.com/en-us/library/system.security.cryptography.mactripledes(v=vs.110).aspx">MACTripleDES Class</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://msdn.microsoft.com/en-us/library/system.security.cryptography.ripemd160(v=vs.110).aspx">RIPEMD160 Class</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://msdn.microsoft.com/en-us/library/system.security.cryptography(v=vs.110).aspx">System.Security.Cryptography Namespace</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://msdn.microsoft.com/en-us/library/system.io.path_methods(v=vs.110).aspx">Path Methods</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="http://go.microsoft.com/fwlink/?LinkID=113418">Test-Path</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="http://stackoverflow.com/questions/21252824/how-do-i-get-powershell-4-cmdlets-such-as-test-netconnection-to-work-on-windows">How do I get PowerShell 4 cmdlets such as Test-NetConnection to work on Windows 7?</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="http://windowsitpro.com/scripting/calculate-md5-and-sha1-file-hashes-using-powershell">Calculate MD5 and SHA1 File Hashes Using PowerShell</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://gist.github.com/quentinproust/8d3bd11562a12446644f">remove-duplicate-files.ps1</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="http://poshcode.org/2154">Get-FileHash.ps1</a></td>
    </tr>
    <tr>
        <td style="padding:6px">ASCII Art: <a href="http://www.figlet.org/">http://www.figlet.org/</a> and <a href="http://www.network-science.de/ascii/">ASCII Art Text Generator</a></td>
    </tr>
</table>




### Related scripts

 <table>
    <tr>
        <th><img class="emoji" title="www" alt="www" height="28" width="28" align="absmiddle" src="https://assets-cdn.github.com/images/icons/emoji/unicode/0023-20e3.png"></th>
        <td style="padding:6px"><a href="https://gist.github.com/auberginehill/aa812bfa79fa19fbd880b97bdc22e2c1">Disable-Defrag</a></td>
    </tr>
    <tr>
        <th rowspan="24"></th>
        <td style="padding:6px"><a href="https://github.com/auberginehill/firefox-customization-files">Firefox Customization Files</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-ascii-table">Get-AsciiTable</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-battery-info">Get-BatteryInfo</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-computer-info">Get-ComputerInfo</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-culture-tables">Get-CultureTables</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-directory-size">Get-DirectorySize</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-hash-value">Get-HashValue</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-installed-programs">Get-InstalledPrograms</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-installed-windows-updates">Get-InstalledWindowsUpdates</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-powershell-aliases-table">Get-PowerShellAliasesTable</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://gist.github.com/auberginehill/9c2f26146a0c9d3d1f30ef0395b6e6f5">Get-PowerShellSpecialFolders</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-ram-info">Get-RAMInfo</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://gist.github.com/auberginehill/eb07d0c781c09ea868123bf519374ee8">Get-TimeDifference</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-time-zone-table">Get-TimeZoneTable</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/get-unused-drive-letters">Get-UnusedDriveLetters</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/emoji-table">Emoji Table</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/java-update">Java-Update</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/remove-empty-folders">Remove-EmptyFolders</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://gist.github.com/auberginehill/13bb9f56dc0882bf5e85a8f88ccd4610">Remove-EmptyFoldersLite</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://gist.github.com/auberginehill/176774de38ebb3234b633c5fbc6f9e41">Rename-Files</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/rock-paper-scissors">Rock-Paper-Scissors</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/toss-a-coin">Toss-a-Coin</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/update-adobe-flash-player">Update-AdobeFlashPlayer</a></td>
    </tr>
    <tr>
        <td style="padding:6px"><a href="https://github.com/auberginehill/update-mozilla-firefox">Update-MozillaFirefox</a></td>
    </tr>
</table>
