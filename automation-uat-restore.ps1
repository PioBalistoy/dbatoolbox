##This script is for automating the copu of backups from a network path $NetworkShare to $SQLDestination Server on the path $BackupDirectory. 
##Only copy the latest full and diffirential backups for each of the databases in the $databases list. 
##Before copying the backups, make sure there is at least 800 GB of freespace on $BackupDirectory. 
##Delete the oldest backups on the $BackupDirecotry under Completed folder.
## Monitor the copy and then send an email to $Recipient wwhen the copy is completed, failed or if is still in progress after 8 hours. Include the log or current progress in the email.
##generate the code for this.

# Define variables
$NetworkShare = "\\network\backup"
$SQLDestination = "SQLServer"
$BackupDirectory = "C:\Backup"
$Databases = @("Database1", "Database2", "Database3")
$Recipient = "email@example.com"

# Check free space on BackupDirectory
$FreeSpace = (Get-PSDrive -Name "C").Free
$RequiredSpace = 800GB

if ($FreeSpace -lt $RequiredSpace) {
    Write-Host "Insufficient free space on $BackupDirectory. Aborting."
    exit
}

# Copy latest backups for each database
foreach ($Database in $Databases) {
    $LatestFullBackup = Get-ChildItem -Path "$NetworkShare\$Database" -Filter "*.full" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1
    $LatestDiffBackup = Get-ChildItem -Path "$NetworkShare\$Database" -Filter "*.diff" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1

    if ($LatestFullBackup -and $LatestDiffBackup) {
        Copy-Item -Path $LatestFullBackup.FullName -Destination "$BackupDirectory\$Database" -Force
        Copy-Item -Path $LatestDiffBackup.FullName -Destination "$BackupDirectory\$Database" -Force
    }
}

# Delete oldest backups in Completed folder
$CompletedFolder = "$BackupDirectory\Completed"
$OldestBackups = Get-ChildItem -Path $CompletedFolder | Sort-Object -Property LastWriteTime | Select-Object -First 5

foreach ($Backup in $OldestBackups) {
    Remove-Item -Path $Backup.FullName -Force
}

# Monitor copy progress and send email
$StartTime = Get-Date
$ElapsedTime = New-TimeSpan -Start $StartTime

while ($ElapsedTime.TotalHours -lt 8) {
    $InProgress = Get-ChildItem -Path "$BackupDirectory\InProgress" -Recurse

    if ($InProgress) {
        # Send email with progress
        $EmailSubject = "Backup Copy In Progress"
        $EmailBody = "The backup copy is still in progress. Please check the attached log for details."
        Send-MailMessage -To $Recipient -From "noreply@example.com" -Subject $EmailSubject -Body $EmailBody -Attachments "$BackupDirectory\log.txt"
    } else {
        # Send email with completion
        $EmailSubject = "Backup Copy Completed"
        $EmailBody = "The backup copy has been completed successfully."
        Send-MailMessage -To $Recipient -From "noreply@example.com" -Subject $EmailSubject -Body $EmailBody
        break
    }

    Start-Sleep -Seconds 300
    $ElapsedTime = New-TimeSpan -Start $StartTime
}

if ($ElapsedTime.TotalHours -ge 8) {
    # Send email with failure
    $EmailSubject = "Backup Copy Failed"
    $EmailBody = "The backup copy has failed. Please check the attached log for details."
    Send-MailMessage -To $Recipient -From "noreply@example.com" -Subject $EmailSubject -Body $EmailBody -Attachments "$BackupDirectory\log.txt"
}