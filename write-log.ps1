## This is a function that write log file for powershell processes.
##  the function will accepte the following parameters:
##  $Severity with possible values of  INFO, WaRNINg and ERROR. The default value for it is INFO. This classfies the message.
## $Message which will contains the message to log.
## $Logfile which will specify the directory to put the file. The default would be the current location. If the parameter passed is just a folder location,
##the logfile name will be the script name with .log extension. If a file name is passed, the log will be written to that file.
## $Append which will specify if the log should be appended to the file or not. The default value is $true. If the logfile does not exists, it will be created.
## $Overwrite which will specify if the log file should be overwritten if it exists. The default value is $false. If this is set to $true, the $Append parameter will be ignored. If this is $false and $append is $false, the log file will be created with the date and time as suffix in the format of yyyyMMdd-HHmmss before the file extension. This filename will be returned as output.
## That's all the parameters. Every Message written to the log file will be preffixed with the current data and time in the format of yyyy-MM-dd HH:mm:ss. The line should be DateTime: [Severity] : Message. The log file should be created if it does not exist. If the log file is created, the first line should be the current date and time in the format of yyyy-MM-dd HH:mm:ss. Then termintaed ith a new line.
## The log file should be created with the UTF-8 encoding.
## The first line will always be "yyyy-MM-dd HH:mm:ss: [INFO]: Log file created. Called by ScriptName.ps1"
## The function returns the log file name of the log file created.
## The function should be called with the following parameters:
## Write-Log -Message "This is a test message" -Severity INFO -Logfile "C:\Logs\ScriptName.log" -Append $true -Overwrite $false
function Write-Log {
    param(
        [Parameter(Position=0, Mandatory=$false)]
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$Severity = "INFO",
        
        [Parameter(Position=1, Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Position=2, Mandatory=$false)]
        [string]$Logfile = (Join-Path -Path $PSScriptRoot -ChildPath "$($MyInvocation.MyCommand.Name.Split('.')[0]).log"),
        
        [Parameter(Position=3, Mandatory=$false)]
        [bool]$Append = $true,
        
        [Parameter(Position=4, Mandatory=$false)]
        [bool]$Overwrite = $false
    )
    $logDateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$logDateTime`: [$Severity] : $Message"
    write-host $LogEntry
    if (-not (Test-Path -Path $Logfile)) {
        $logFileCreated = $true
        $logFileContent = "$logDateTime`: [INFO]: Log file created. Called by $($MyInvocation.MyCommand.Name)"
        $logFileContent | Out-File -FilePath $Logfile -Encoding UTF8
       
    }

    if ($Overwrite) {
        $logFileContent = "$logDateTime`: [INFO]: Log file overwritten. Called by $($MyInvocation.MyCommand.Name)"
        $logFileContent | Out-File -FilePath $Logfile -Encoding UTF8
       
    }
    elseif (-not $Append) {
        $logFileCreated = $true
        $logFileSuffix = Get-Date -Format "yyyyMMdd-HHmmss"
        $logFileExtension = [System.IO.Path]::GetExtension($Logfile)
        $logFileBaseName = [System.IO.Path]::GetFileNameWithoutExtension($Logfile)
        $logFileNewName = "$logFileBaseName-$logFileSuffix$logFileExtension"
        $logFileContent = "$logDateTime`: [INFO]: Log file created. Called by $($MyInvocation.MyCommand.Name)"
        $logFileContent | Out-File -FilePath $logFileNewName -Encoding UTF8
       
    }

    if (-not $logFileCreated) {
        $logFileContent = $logEntry
        $logFileContent | Out-File -FilePath $Logfile -Append -Encoding UTF8
        
    }


return $LOgfile
}
