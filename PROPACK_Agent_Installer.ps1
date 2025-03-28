$TypeOfInstaller="Installer"
$LocationType="http"
$httpPath="http://aindaleng200.co.uk/ts/MSI/QualysCloudAgent.exe"

$PackageName="QualysCloudAgent.exe"
$InstallationParameter="CustomerId={7e75b125-bde1-5266-82b3-1554611e3a16} ActivationId={699c0970-6071-4d75-baa4-148dd1e41320} WebServiceUri=https://qagpublic.qg2.apps.qualys.eu/CloudAgent/"
$InstallExecuteMode="Install"
$InstallerTypeOfApplication="exe"

if ($env:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    if ($myInvocation.Line) {
        &"$env:systemroot\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile $myInvocation.Line
    }
    else {
        &"$env:systemroot\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile -file "$($myInvocation.InvocationName)" $args
    }
    exit $lastexitcode
}
#Parameter Validation region
if ( ($TypeOfInstaller -eq "Installer") -and ($PackageName.EndsWith(".$InstallerTypeOfApplication") -ne $InstallerTypeOfApplication) ){
    Write-Error "Type of Application and the Package name extension is not matching. Please correct the package name extension(exe/msi) according to the Type of Application you have selected."
    Exit
}

#if ( ($TypeOfInstaller -eq "Installer") -and ($PackageName.Split(".")[1] -ne $InstallerTypeOfApplication) ){
#   Write-Error "Type of Application and the Package name extension is not matching. Please correct the package name extension(exe/msi) according to the Type of Application you have selected."
#   Exit
#}

#region Functions
function Get-MD5Hash ($path) {
    $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
    return [System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($path))) -replace '-', ''
}

Function Download-FromURLInvoke ($URL, $LocalFilePath) {
    try {
        # Write-Host "Downloading: $URL"
            Import-Module BitsTransfer
            $ProgressPreference = "SilentlyContinue"
            Start-BitsTransfer -Source $URL -Destination $LocalFilePath
        if (-not(Test-Path $LocalFilePath)) { Write-Error "Unable to download the file from URL: $URL" }
    }
    catch {
        Write-Error "Unable to download the file from URL: $URL`n$($_.Exception.Message)"
    }
}

function Download-FromURL ($URL, $LocalFilePath) {
    try {
        # Write-Host "Downloading: $URL"
        [uri]$url = $url
        $Client = New-Object System.Net.WebClient
        $Client.DownloadFile($URL, $LocalFilePath)
        if (-not(Test-Path $LocalFilePath)) {
        
            if($PSVersionTable.PSVersion.Major -ge "3")
            {
              Download-FromURLInvoke -URL $url -LocalFilePath $LocalFilePath
            }
            else
            {
             Write-Error "Unable to download the file from URL: $URL"
            }
        }
    }
    catch {
        if($PSVersionTable.PSVersion.Major -ge "3")
        {
        Download-FromURLInvoke -URL $url -LocalFilePath $LocalFilePath
        }
        else
        {
         Write-Error "Unable to download the file from URL: $URL`n$($_.Exception.Message)"

        }
    }
}

Function Validate_urlInvoke($url){

    $ProgressPreference = 'SilentlyContinue'  ## for the progress not to pop up on the screen.
    $HTTP_Status=(Invoke-WebRequest -Uri $url -UseBasicParsing -DisableKeepAlive).StatusCode
        if($HTTP_Status -eq 200){return 1}else{return 0}
}

Function Validate_url($url, $username, $password, $protocol){
   if($protocol -eq 'http' -or $protocol -eq 'https'){
        $ErrorActionPreference = "SilentlyContinue"
        $HTTP_Request = [System.Net.WebRequest]::Create("$url")
        try{
        $HTTP_Response = $HTTP_Request.GetResponse()
        }
        catch{
        if($PSVersionTable.PSVersion.Major -ge "3")
        {
            try{
                $op=Validate_urlInvoke -url $url
                return $op
                }
            catch{
                    return 0
                  }
        }
        else
        {
        return 0
        }
        }
        $HTTP_Status = [int]$HTTP_Response.StatusCode
        $ErrorActionPreference = "Continue"
        if($HTTP_Status -eq 200){return 1}else{return 0}
    }
    if($protocol -eq 'ftp'){
        $ErrorActionPreference = "SilentlyContinue"
        $ftprequest = [System.Net.FtpWebRequest]::Create("$url")
        $ftprequest.Credentials = New-Object System.Net.NetworkCredential("$username", "$password") 
        $FTPRequest.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile
        try{$ftpstatus = $ftprequest.GetResponse()}catch{return 0}
        $ErrorActionPreference = "Continue"
        if($ftpstatus){return $url}else{return 0}
    }
}

function Download-FromFTP ($RemoteFTPFilePath, $LocalFilePath, $UserName, $Password) {
    try {
        # Write-Host "Downloading: $RemoteFTPFilePath"
        $ftprequest = [System.Net.FtpWebRequest]::create($RemoteFTPFilePath)
        $ftprequest.Credentials = New-Object System.Net.NetworkCredential($username, $password)
        $ftprequest.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile
        $ftprequest.UseBinary = $true
        $ftprequest.KeepAlive = $false
        $ftpresponse = $ftprequest.GetResponse()
        $responsestream = $ftpresponse.GetResponseStream()
        $targetfile = New-Object IO.FileStream ($LocalFilePath, [IO.FileMode]::Create)
        [byte[]]$readbuffer = New-Object byte[] 1024

        do {
            $readlength = $responsestream.Read($readbuffer, 0, 1024)
            $targetfile.Write($readbuffer, 0, $readlength)
        }
        while ($readlength -ne 0)
        $targetfile.close()

        if (-not (Test-Path $LocalFilePath)) { Write-Error "Unable to download the file from FTP location: $RemoteFTPFilePath" }

    }
    catch {
        Write-Error "Unable to download the file from FTP location: $RemoteFTPFilePath`n$($_.Exception.Message)"
    }
}

function Download-FromUNC ($RemoteUNCFilePath, $PackageName, $LocalFilePath, $UserName, $Password) {
    try {
        # Write-Host "Downloading: $(Join-Path $RemoteUNCFilePath $PackageName)"
        $FreeDriveLetter = Get-RandomFreeDriveLetter
        MapNetworkDrive -DriveLetter $FreeDriveLetter -Directory $RemoteUNCFilePath -Persistent $false -Username $UserName -Password $Password
        Copy-Item $(Join-Path $FreeDriveLetter $PackageName) -Destination $LocalFilePath
        if (-not (Test-Path $LocalFilePath)) { Write-Error "Unable to download the file from Network location: $RemoteUNCFilePath" }
    }
    catch {
        Write-Error "Unable to download the file from Network location: $RemoteUNCFilePath`n$($_.Exception.Message)"
    }
    finally {
        try {
            $Network = New-Object -ComObject WScript.Network
            $Network.RemoveNetworkDrive($FreeDriveLetter, $True)
        }
        catch {
            # no action
        }
    }
}

Function MapNetworkDrive($DriveLetter, $Directory, $Persistent, $Username, $Password) {
    try {
        if (Test-Path $DriveLetter) {
            # Write-Output "`n[Map Network Drive] Failed to Map the network drive: `'$DriveLetter`' because it already exists."
            Write-Error "Failed to Map the network drive: `'$DriveLetter`' because it already exists."
        }
        else {
            $Network = New-Object -ComObject WScript.Network
            $Network.MapNetworkDrive($DriveLetter, "$Directory", $Persistent, $UserName, $Password)
        }
    }
    catch {
        Write-Error "Failed to Map the network drive.`n$($_.Exception.Message)"
    }
}

function Join-URLParts {
    param ([string[]] $Parts, [string] $Seperator = '')
    $search = '(?<!:)' + [regex]::Escape($Seperator) + '+'  #Replace multiples except in front of a colon for URLs.
    $replace = $Seperator
    ($Parts | Where-Object { $_ -and $_.Trim().Length }) -join $Seperator -replace $search, $replace
}

function Get-RandomFreeDriveLetter {
    Get-ChildItem function:[d-z]: -n | Where-Object { !(test-path $_) } | Get-Random
}


function Write-SuccessOrFail ([System.Diagnostics.Process]$Process, $PackageName, $Action) {
    If ($process.exitcode -eq 0) {
        Write-Output "`n$Action of '$PackageName' Successful."
    }
    else {
        Write-Error "`n$Action of '$PackageName' Failed. Exitcode: $($process.exitcode)"
    }
}

function Test-Registry ($Key, $Value, $Data) {
    $Path = "REGISTRY::$key"
    $KeyExists = Test-Path $Path
    $Result = Get-ItemProperty "REGISTRY::$key" -Name $Value -ErrorAction SilentlyContinue
    $ValueExists = [bool](($Result).$value)
    $DataMatches = $data -eq ($Result).$value

    return $KeyExists, $ValueExists, $DataMatches
}

function Test-FileVersion ($Path, [System.Version]$UserSpecifiedVersion) {
    $FileExists = Test-Path $Path
    $versioninfo = (Get-Item $path -ErrorAction SilentlyContinue).versioninfo
    $FileVersion = [System.Version] ("{0}.{1}.{2}.{3}" -f $versioninfo.FileMajorPart, $versioninfo.FileMinorPart, $versioninfo.FileBuildPart, $versioninfo.FilePrivatePart)
    $FileVersionMatches = $FileVersion -eq $UserSpecifiedVersion
    $FileVersionGreater = $FileVersion -gt $UserSpecifiedVersion
    $FileVersionLower = $FileVersion -lt $UserSpecifiedVersion

    $FileExists, $FileVersionMatches, $FileVersionGreater, $FileVersionLower
}

Function Test-AddRemoveProgram ($Program) {
    $Registry = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
    $product = Get-ChildItem $Registry -ErrorAction 'SilentlyContinue' | Get-ItemProperty | Where-Object { $_.Displayname -eq $program }
    return [bool] $product
}


#endregion Functions

#region Main
$ErrorActionPreference = 'Stop'

try {
    #region PreCheck
    if ($PerformPreCheck) {
        $Name = 'Pre-Check'
        Switch ($PreCheckType) {
            'Check if file exists' {
                $FileExists = Test-Path $PreCheckFileName
                $PreCheckAction = $PreCheckAction_for_PreCheckType_1  # handle Narayan's request to have multiple $PreCheckAction_for_PreCheckType_[n] variables substituted through JSON
                Switch ($PreCheckAction) {
                    'If file exists then Continue' { if ($FileExists) { continue } else { Write-Output "Aborting because $Name condition was not met `'$PreCheckAction`'"; return } }
                    'If file does not exists then Continue' { if (-not $FileExists) { continue } else { Write-Output "Aborting because $Name condition was not met `'$PreCheckAction`'"; return } }
                    'If file exists then Abort' { if ($FileExists) { Write-Output "Aborting because $Name condition was met `'$PreCheckAction`'"; return } else { continue } }
                    'If file does not exists then Abort' { if (-not $FileExists) { Write-Output "Aborting because $Name condition was met `'$PreCheckAction`'"; return } else { continue } }
                }
                break;
            }
            'Check if registry information exists' {
                $KeyExists, $ValueMatches, $DataMatches = Test-Registry -Key $PreCheckKey -Value $PreCheckValue -Data $PreCheckData
                $PreCheckAction = $PreCheckAction_for_PreCheckType_2 # handle Narayan's request to have multiple $PreCheckAction_for_PreCheckType_[n] variables substituted through JSON
                Switch ($PreCheckAction) {
                    'If key exists then Continue' { if ($KeyExists) { continue } else { Write-Output "Aborting because $Name condition was not met `'$PreCheckAction`'"; return } }
                    'If key does not exists then Continue' { if (-not $KeyExists) { continue } else { Write-Output "Aborting because $Name condition was not met `'$PreCheckAction`'"; return } }
                    'If key exists then Abort' { if ($KeyExists) { Write-Output "Aborting because $Name condition was met `'$PreCheckAction`'"; return } else { continue } }
                    'If key not exists then Abort' { if (-not $KeyExists) { Write-Output "Aborting because $Name condition was met `'$PreCheckAction`'"; return } else { continue } }
                    'If key exists and value matches then Continue' { if ($KeyExists -and $ValueMatches) { continue } else { Write-Output "Aborting because $Name condition was not met `'$PreCheckAction`'"; return } }
                    'If key exists and value does not matches then Continue' { if ($KeyExists -and (-not $ValueMatches)) { continue } else { Write-Output "Aborting because $Name condition was not met `'$PreCheckAction`'"; return } }
                    'If key exists and value matches then Abort' { if ($KeyExists -and $ValueMatches) { Write-Output "Aborting because $Name condition was met `'$PreCheckAction`'"; return } else { continue } }
                    'If key exists and value does not matches then Abort' { if ($KeyExists -and (-not $ValueMatches)) { Write-Output "Aborting because $Name condition was met `'$PreCheckAction`'"; return } else { continue } }
                    'If key exists and value exists and data matches then Continue' { if ($KeyExists -and $datamatches) { continue } else { Write-Output "Aborting because $Name condition was not met `'$PreCheckAction`'"; return } }
                    'If key exists and value exists and data does not matches then Continue' { if ($KeyExists -and $ValueMatches -and (-not $datamatches)) { continue } else { Write-Output "Aborting because $Name condition was not met `'$PreCheckAction`'"; return } }
                    'If key exists and value exists and data matches then Abort' { if ($KeyExists -and $ValueMatches -and $datamatches) { Write-Output "Aborting because $Name condition was met `'$PreCheckAction`'"; return } else { continue } }
                    'If key exists and value exists and data does not matches then Abort' { if ($KeyExists -and $ValueMatches -and (-not $datamatches)) { Write-Output "Aborting because $Name condition was met `'$PreCheckAction`'"; return } else { continue } }
                }
                break;
            }
            'Check if Add / Remove program exists' {
                $ProgramExists = Test-AddRemoveProgram -Program $PreCheckProgram
                $PreCheckAction = $PreCheckAction_for_PreCheckType_3 # handle Narayan's request to have multiple $PreCheckAction_for_PreCheckType_[n] variables substituted through JSON

                Switch ($PreCheckAction) {
                    'If the program exists then continue' { if ($ProgramExists) { continue } else { Write-Output "Aborting because $Name condition was not met `'$PreCheckAction`'"; return } }
                    'If the program does not exists then continue' { if (!$ProgramExists) { continue } else { Write-Output "Aborting because $Name condition was not met `'$PreCheckAction`'"; return } }
                    'If the program exists then abort' { if ($ProgramExists) { Write-Output "Aborting because $Name condition was met `'$PreCheckAction`'"; return } else { continue } }
                    'If the program does not exists then abort' { if (!$ProgramExists) { Write-Output "Aborting because $Name condition was met `'$PreCheckAction`'"; return } else { continue } }
                }
                break;
            }
            'Check for file version' {
                $FileExists, $FileVersionMatches, $FileVersionGreater, $FileVersionLower = Test-FileVersion -Path $PreCheckFileName -UserSpecifiedVersion $PreCheckVersion
                $PreCheckAction = $PreCheckAction_for_PreCheckType_4 # handle Narayan's request to have multiple $PreCheckAction_for_PreCheckType_[n] variables substituted through JSON

                Switch ($PreCheckAction) {
                    'If file exists and version equal to specified then Continue' { if ($FileExists -and $FileVersionMatches) { continue } else { Write-Output "Aborting because $Name condition was not met `'$PreCheckAction`'"; return } }
                    'If file exists and version not equal to specified then Continue' { if ($FileExists -and (-not $FileVersionMatches)) { continue } else { Write-Output "Aborting because $Name condition was not met `'$PreCheckAction`'"; return } }
                    'If file exists and version higher to specified then Continue' { if ($FileExists -and $FileVersionGreater) { continue } else { Write-Output "Aborting because $Name condition was not met `'$PreCheckAction`'"; return } }
                    'If file exists and version lower to specified then Continue' { if ($FileExists -and $FileVersionLower) { continue } else { Write-Output "Aborting because $Name condition was not met `'$PreCheckAction`'"; return } }
                    'If file exists and version equal to specified then Abort' { if ($FileExists -and $FileVersionMatches) { Write-Output "Aborting because $Name condition was met `'$PreCheckAction`'"; return } else { continue } }
                    'If file exists and version not equal to specified then Abort' { if ($FileExists -and (-not $FileVersionMatches)) { Write-Output "Aborting because $Name condition was met `'$PreCheckAction`'"; return } else { continue } }
                    'If file exists and version higher to specified then Abort' { if ($FileExists -and $FileVersionGreater) { Write-Output "Aborting because $Name condition was met `'$PreCheckAction`'"; return } else { continue } }
                    'If file exists and version lower to specified then Abort' { if ($FileExists -and $FileVersionLower) { Write-Output "Aborting because $Name condition was met `'$PreCheckAction`'"; return } else { continue } }
                    'If file does not exists then Abort' { if (-not $FileExists) { Write-Output "Aborting because $Name condition was met `'$PreCheckAction`'"; return } else { continue } }
                }
                break;
            }
        }
    }
    #endregion Precheck

    #region Main
    Switch ($TypeOfInstaller) {
        'Installer' {
            $PackageLocalPath = Join-Path $env:TEMP $PackageName

            #region InputValidation
            switch ($LocationType) {
                'ftp' {
                    $location = $ftpPath #+ "/" + $PackageName
                    $Scheme = ([uri]$Location).scheme
                    if ($Scheme -and ($Scheme -ne 'ftp')) {
                        Write-Error "Invalid `'$LocationType`' URL: $Location"
                    }
                    elseif (!($Location.StartsWith("ftp://"))) {
                        $Location = "ftp://" + $Location
                    }
                    if(($ftppath -like "*\") -or ($ftppath -like "*/")){$ftppath = $ftppath.subString(0,$ftppath.length-1)}
                    $location = Validate_url -url $ftppath -username $username -password $password -protocol 'ftp'
                    if($location -eq 0){
                        $ftppath = $ftppath + "/" + $Packagename
                        $location = Validate_url -url $ftppath -username $username -password $password -protocol 'ftp'
                    }
                    if($location -eq 0){Write-Error "URL provided is invalid.";Exit;}
                    break;
                }
                'http' {
                    $Scheme = ([uri]$httppath).scheme
                    if ($Scheme -and ($Scheme -ne 'http')) {
                        Write-Error "Invalid `'$LocationType`' URL: $httppath"
                    }
                    elseif (!($httppath.StartsWith("http://"))) {
                        $httppath = "http://" + $httspath
                    }
                    if(($httppath -like "*\") -or ($httppath -like "*/")){$httppath = $httppath.subString(0,$httppath.length-1)}
                    $location = Validate_url -url $httppath -protocol 'http'
                    if($location -eq 1){$location = $httppath}
                    if($location -eq 0){
                       $httppath = $httpPath + "/" + $PackageName
                       $location = Validate_url -url $httppath -protocol 'http'
                       if($location -eq 1){$location = $httppath}  
                    }
                    if($location -eq 0){Write-Error "URL provided is invalid.";Exit;}
                   
                    break;
                }
                'https' {
                    $Scheme = ([uri]$httpspath).scheme
                    if ($Scheme -and ($Scheme -ne 'https')) {
                        Write-Error "Invalid `'$LocationType`' URL: $httpspath"
                    }
                    elseif (!($httpspath.StartsWith("https://"))) {
                        $httpspath = "https://" + $httpspath
                    }
                    $ErrorActionPreference = "SilentlyContinue"
                    try{
                    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType] 'Ssl3, Tls, Tls11, Tls12'
                    }
                    catch
                    {
                    $ErrorActionPreference = "Continue"
                    Write-Error "Unable to download the file from URL: $httpspath. The download URL requires TLS 1.2 protocol which is not supported in Powershell v2.0 (Windows 7 & 2008 R2)."
                    Exit
                    }
                    #if(!$?){$ErrorActionPreference = "Continue";Write-Error "Download from the URL has failed. It might be an issue while establishing SSL\TLS secure channel between client and the server, as this machine only supports following version of secure protocols: $([enum]::GetNames([System.Net.SecurityProtocolType]) -join ', ') through the Task.";Exit;}
                    $ErrorActionPreference = "Continue"
                    if(($httpspath -like "*\") -or ($httpspath -like "*/")){$httpspath = $httpspath.subString(0,$httpspath.length-1)}
                    $location = Validate_url -url $httpspath -protocol 'https'
                    if($location -eq 1){$location = $httpspath}
                    if($location -eq 0){
                       $httpspath = $httpsPath + "/" + $PackageName
                       $location = Validate_url -url $httpspath -protocol 'https' 
                       if($location -eq 1){$location = $httpspath}
                    }
                    if($location -eq 0){Write-Error "URL provided is invalid.";Exit;}
                   
                    break;
                }
                'network' {
                    $location = $networkPath
                    if(($location -like "*.exe") -or ($location -like "*.msi")){
                        $location = Split-Path $location
                    }
                    if(($location -like "*\") -or ($location -like "*/")){$location = $location.subString(0,$location.length-1)}
                    $Scheme = ([uri]$Location).scheme
                    $isUNC = ([uri]$Location).isUNC

                    if ($Scheme -and ($Scheme -ne 'file')) {
                        # condition to check wrong scheme, like 'http' in case of 'ftp'
                        Write-Error "Invalid `'$LocationType`' Path: $Location"
                    }
                    elseif ($Scheme -and ($Scheme -eq 'file') -and !$isUNC) {
                        # has the correct scheme, but a local path
                        Write-Error "Invalid `'$LocationType`' Path: $Location"
                    }
                    elseif (!($Location.StartsWith("\\"))) {
                        $Location = "\\" + $Location
                    }
                    break;
                }
                'local' {
                    if(($localPath -like "*.exe") -or ($localPath -like "*.msi")){
                        $location = $localPath
                    }else{
                        $location = Join-Path $localPath $PackageName
                    }
                    

                    $Scheme = ([uri]$Location).scheme
                    $isUNC = ([uri]$Location).isUNC

                    if ($Scheme -and ($Scheme -ne 'file')) {
                        # condition to check wrong scheme, like 'http' in case of 'ftp'
                        Write-Error "Invalid `'$LocationType`' Path: $Location"
                    }
                    elseif ($Scheme -and ($Scheme -eq 'file') -and $isUNC) {
                        # has the correct scheme, but a network path
                        Write-Error "Invalid `'$LocationType`' Path: $Location"
                    }

                    if (!(Test-Path $($location))) {
                        Write-Error "Local path not found: $(Join-Path $Location)"
                    }

                    break;
                }
            }
            #endregion InputValidation

            #region DownloadPackage
            switch (([uri]$Location).scheme) {
                'ftp' {
                    $RemoteFTPFilePath = $location
                    Download-FromFTP $RemoteFTPFilePath $PackageLocalPath $Username $Password
                    Break;
                }
                'http' { Download-FromURL $Location $PackageLocalPath ; 
                        $Nametocheck = (Get-item $PackageLocalPath).FullName
                        $nametoupdate = (Get-item $PackageLocalPath).Name
                        
                        
                        if(!($Nametocheck -like "*.exe") -and !($Nametocheck -like "*.msi") ){
                            if($InstallerTypeOfapplication -eq "msi"){$updatedname = $nametoupdate + ".msi";Rename-Item $Nametocheck -NewName $updatedname -Force;$PackageLocalPath = $PackageLocalPath + ".msi";$PackageName = $PackageName + ".msi"}
                            if($InstallerTypeOfapplication -eq "exe"){$updatedname = $nametoupdate + ".exe";Rename-Item $Nametocheck -NewName $updatedname -Force;$PackageLocalPath = $PackageLocalPath + ".exe";$PackageName = $PackageName + ".exe"}
                         }
                        Break; }
                'https' {
                    try{
                        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType] 'Ssl3, Tls, Tls11, Tls12'
                    }
                    catch {
                        $TLSEnforce = $false
                    }
                    try{
                        Download-FromURL $Location $PackageLocalPath ; 
                        $Nametocheck = (Get-item $PackageLocalPath).FullName
                        $nametoupdate = (Get-item $PackageLocalPath).Name
                        
                        
                        if(!($Nametocheck -like "*.exe") -and !($Nametocheck -like "*.msi") ){
                            if($InstallerTypeOfapplication -eq "msi"){$updatedname = $nametoupdate + ".msi";Rename-Item $Nametocheck -NewName $updatedname -Force;$PackageLocalPath = $PackageLocalPath + ".msi";$PackageName = $PackageName + ".msi"}
                            if($InstallerTypeOfapplication -eq "exe"){$updatedname = $nametoupdate + ".exe";Rename-Item $Nametocheck -NewName $updatedname -Force;$PackageLocalPath = $PackageLocalPath + ".exe";$PackageName = $PackageName + ".exe"}
                         }
                        Break;
                    }
                    catch {
                        if(!$TLSEnforce){
                            Write-Error "Download from the URL has failed. It might be an issue while establishing SSL\TLS secure channel between client and the server, as this machine only supports following version of secure protocols: $([enum]::GetNames([System.Net.SecurityProtocolType]) -join ', ') through the Task."
                            Write-Error "Workaround: Try downloading the file from HTTP variant of the URL, if it exists. Or copy the exe\msi on a UNC (Network Share) path and then execute the setup using this script"
                        }
                        else {
                            Write-Error $_.Exception.Message
                        }
                    }
                }
                'file' {
                    if (([uri]$Location).IsUnc) {
                        # if the location is a shared UNC path
                        Download-FromUNC $Location $PackageName $PackageLocalPath $UserName $Password
                    }
                    else {
                        # if the location is a local system path
                        $PackageLocalPath =  $Location
                    }
                    Break;
                }
                default {
                    Write-Error "Failed. Not a valid user input for package 'Location', please validate the input and try again."
                }
            }
            #endregion DownloadPackage

            # validate checksum of donwloaded file
            if ($MD5CheckSum -and $(Get-MD5Hash $PackageLocalPath) -ne $MD5CheckSum) {
                Write-Error "MD5 Checksum: '$MD5CheckSum' did not match with the MD5 Checksum of Package:'$PackageName'"
            }

            #region Install

            $InstallExecuteMode = "Install" # as per Narayan's request hardcoded this value for now, and will implement others once we have a clarity on this
            Switch ($InstallExecuteMode){
                'Install' {
                    switch ($InstallerTypeOfapplication) {
                        'exe' {
                            # Write-Host "Installing: $PackageLocalPath $InstallationParameter"
                            if (![string]::IsNullOrEmpty($InstallationParameter)) {
                                $InstallationParameter = $InstallationParameter.trim()
                                $Process = Start-Process -FilePath $PackageLocalPath -ArgumentList $InstallationParameter -Wait -PassThru
                            }
                            else {
                                $Process = Start-Process -FilePath $PackageLocalPath -Wait -PassThru
                            }

                            if (!$PerformPostCheck) {
                                Write-SuccessOrFail -Process $Process -PackageName $PackageName -Action 'Installation'
                            }
                        }
                        'msi' {
                            # Write-Host "Installing: $env:systemroot\system32\msiexec.exe /i $PackageLocalPath $InstallationParameter"
                            if (![string]::IsNullOrEmpty($InstallationParameter)) {
                                $MSIArgs = @(
                                    "/i"
                                    $PackageLocalPath
                                    #Modified to remove "msiexec.exe /i" or "/i" from the installation parameter - Narayan.
                                    $InstallationParameter -replace "msiexec.*.msi","" -replace "/i", "" -replace " .*\.msi","" | ForEach-Object {$_.trim()}
                                )
                            }
                            else {
                                $MSIArgs = @(
                                    "/i"
                                    $PackageLocalPath
                                )
                            }

                            $Process = Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList $MSIArgs -Wait -PassThru

                            if (!$PerformPostCheck) {
                                Write-SuccessOrFail -Process $Process -PackageName $PackageName -Action 'Installation'
                            }
                        }
                    }
                }
                'Install From Gateway' {
                    # no action defined for now
                }
                'Download to Gateway' {
                    # no action defined for now
                }
            }

            #endregion Install
            break;
        }

        'UnInstaller' {
            #region UnInstall
            $UninstallExecuteMode = "Uninstall" # as per Narayan's request hardcoded this value for now, and will implement others once we have a clarity on this
            Switch ($UninstallExecuteMode){
                'Uninstall' {
                    switch ($UninstallerTypeOfApplication) {
                        'exe' {
                            # Write-Host "UnInstalling: $UninstallationPath $UnInstallationParameter"
                            if ($UnInstallationParameter) {
                                $Process = Start-Process -FilePath $UninstallationPath -ArgumentList "$UnInstallationParameter" -Wait -PassThru
                            }
                            else {
                                $Process = Start-Process -FilePath $UninstallationPath -Wait -PassThru
                            }
                            if (!$PerformPostCheck) {
                                Write-SuccessOrFail -Process $Process -PackageName $UninstallationPath -Action 'UnInstallation'
                            }
                        }
                        'msi' {
                            $Msg = $UninstallationParameter
                            $MSIArgs = ($UninstallationParameter -Replace "msiexec.exe", "" -replace "msiexec", "").trim()
                            # Write-Host "UnInstalling: $env:systemroot\system32\msiexec.exe /i $UnInstallationParameter"

                            $Process = Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList $MSIArgs -Wait -PassThru
                            if (!$PerformPostCheck) {
                                Write-SuccessOrFail -Process $Process -PackageName $Msg -Action 'UnInstallation'
                            }
                        }
                    }
                }
            }

            #endregion UnInstall
            break;
        }
    }
    #endregion Main

    #region PostCheck
    if ($PerformPostCheck) {
        $Name = 'Post-Check'
        Switch ($PostCheckType) {
            'Check if file exists' {
                $FileExists = Test-Path $PostCheckFileName
                $PostCheckAction = $PostCheckAction_for_PostCheckType_1  # handle Narayan's request to have multiple $PostCheckAction_for_PostCheckType_[n] variables substituted through JSON
                Switch ($PostCheckAction) {
                    'If the file exists then mark Success' { if ($FileExists) { Write-Output "Success" } else { Write-Output "Failed" } }
                    'If the file does not exists then mark Success' { if (-not $FileExists) { Write-Output "Success" } else { Write-Output "Failed" } }
                    'If the file exists then mark Fail' { if ($FileExists) { Write-Output "Failed" } else { Write-Output "Success" } }
                    'If the file does not exists then mark Fail' { if (-not $FileExists) { Write-Output "Failed" } else { Write-Output "Success" } }
                }
                break;
            }
            'Check if registry information exists' {
                $KeyExists, $ValueMatches, $DataMatches = Test-Registry -Key $PostCheckKey -Value $PostCheckValue -Data $PostCheckData
                $PostCheckAction = $PostCheckAction_for_PostCheckType_2  # handle Narayan's request to have multiple $PostCheckAction_for_PostCheckType_[n] variables substituted through JSON

                Switch ($PostCheckAction) {
                    'If the key exists then mark success' { if ($KeyExists) { Write-Output "Success" } else { Write-Output "Failed" } }
                    'If the key does not exists then mark success' { if (-not $KeyExists) { Write-Output "Success" } else { Write-Output "Failed" } }
                    'If the key exists then mark fail' { if ($KeyExists) { Write-Output "Failed" } else { Write-Output "Success" } }
                    'If the key not exists then mark fail' { if (-not $KeyExists) { Write-Output "Failed" } else { Write-Output "Success" } }
                    'If the key exists and value matches then mark success' { if ($KeyExists -and $ValueMatches) { Write-Output "Success" } else { Write-Output "Failed" } }
                    'If the key exists and value does not match then mark success' { if ($KeyExists -and (-not $ValueMatches)) { Write-Output "Success" } else { Write-Output "Failed" } }
                    'If the key exists and value matches then mark fail' { if ($KeyExists -and $ValueMatches) { Write-Output "Failed" } else { Write-Output "Success" } }
                    'If the key exists and value does not match then mark fail' { if ($KeyExists -and (-not $ValueMatches)) { Write-Output "Failed" } else { Write-Output "Success" } }
                    'If the key exists and value exists and data matches then mark success' { if ($KeyExists -and $ValueMatches -and $DataMatches) { Write-Output "Success" } else { Write-Output "Failed" } }
                    'If the key exists and value exists and data does not match then mark success' { if ($KeyExists -and $ValueMatches -and (-not $DataMatches)) { Write-Output "Success" } else { Write-Output "Failed" } }
                    'If the key exists and value exists and data matches then mark fail' { if ($KeyExists -and $ValueMatches -and $DataMatches) { Write-Output "Failed" } else { Write-Output "Success" } }
                    'If the key exists and value exists and data does not match then mark fail' { if ($KeyExists -and $ValueMatches -and (-not $DataMatches)) { Write-Output "Failed" } else { Write-Output "Success" } }
                }
                break;
            }
            'Check if Add / Remove program exists' {
                $ProgramExists = Test-AddRemoveProgram -Program $PostCheckProgram
                $PostCheckAction = $PostCheckAction_for_PostCheckType_3  # handle Narayan's request to have multiple $PostCheckAction_for_PostCheckType_[n] variables substituted through JSON

                Switch ($PostCheckAction) {
                    'If the program exists then mark success' { if ($ProgramExists) { Write-Output "Success" } else { Write-Output "Failed" } }
                    'If the program does not exists then mark success' { if (-not $ProgramExists) { Write-Output "Success" } else { Write-Output "Failed" } }
                    'If the program exists then mark fail' { if ($ProgramExists) { Write-Output "Failed" } else { Write-Output "Success" } }
                    'If the program does not exists then mark fail' { if (-not $ProgramExists) { Write-Output "Failed" } else { Write-Output "Success" } }
                }
                break;
            }
            'Check for file version' {
                $FileExists, $FileVersionMatches, $FileVersionGreater, $FileVersionLower = Test-FileVersion -Path $PostCheckFileName -UserSpecifiedVersion $PostCheckVersion
                $PostCheckAction = $PostCheckAction_for_PostCheckType_4  # handle Narayan's request to have multiple $PostCheckAction_for_PostCheckType_[n] variables substituted through JSON

                Switch ($PostCheckAction) {
                    'If the file exists and the version matches then mark success' { if ($FileExists -and $FileVersionMatches) { Write-Output "Success" } else { Write-Output "Failed" } }
                    'If the file exists and version does not match then mark success' { if ($FileExists -and (-not $FileVersionMatches)) { Write-Output "Success" } else { Write-Output "Failed" } }
                    'If the file exists and version is greater than specified then mark success' { if ($FileExists -and $FileVersionGreater) { Write-Output "Success" } else { Write-Output "Failed" } }
                    'If the file exists and version is lower than specified then mark success' { if ($FileExists -and $FileVersionLower) { Write-Output "Success" } else { Write-Output "Failed" } }
                    'If the file exists and the version is matches then mark fail' { if ($FileExists -and $FileVersionMatches) { Write-Output "Failed" } else { Write-Output "Success" } }
                    'If the file exists and version does not match then mark fail' { if ($FileExists -and (-not $FileVersionMatches)) { Write-Output "Failed" } else { Write-Output "Success" } }
                    'If the file exists and version is greater than specified then mark fail' { if ($FileExists -and $FileVersionGreater) { Write-Output "Failed" } else { Write-Output "Success" } }
                    'If the file exists and version is lower than specified then mark fail' { if ($FileExists -and $FileVersionLower) { Write-Output "Failed" } else { Write-Output "Success" } }
                    'If the file does not exists then mark fail' { if (-not $FileExists) { Write-Output "Failed" } else { Write-Output "Success" } }
                }
                break;
            }
        }
    }
    #endregion Postcheck
}
catch {
    Write-Error $_.exception.message
}
finally {
       try{
           Remove-Item $PackageLocalPath -Force -ErrorAction SilentlyContinue
       }catch{}
}