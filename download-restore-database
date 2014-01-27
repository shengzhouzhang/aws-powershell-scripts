#============================================================
# Download Database Backup File with AWS S3 Objects
#============================================================

Import-Module "C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1"

$accessKey = ""                                  # Amazon access key.   
$secretKey = ""              # Amazon secret key.
$creds = New-AWSCredentials -AccessKey $accessKey -SecretKey $secretKey
Set-AWSCredentials -Credentials $creds

$bucketName = "bngconserve"
$localFile = "e:\bng-production-data\data.bak"
$backupFile = $localFile
$logFile = "e:\db_log.txt"

#SMTP server name
$smtpServer = ""      #smtp server

#Creating a Mail object
$msg = new-object Net.Mail.MailMessage

#Creating SMTP server object
$smtp = new-object Net.Mail.SmtpClient($smtpServer, 25)
$smtp.EnableSsl = $true
$smtp.Credentials = New-Object System.Net.NetworkCredential("", "");    #smtp credential

#Email structure 
$msg.From = ""
$msg.To.Add("")
$msg.subject = "BNG Production to Demo Database Restoration"
$msg.body = ""

try {
    echo "Retriving File List from AWS..." > $logFile
    $results = Get-S3Object -BucketName bngconserve -KeyPrefix database/
    $results = $results | Sort-Object -Property LastModified –Descending
    echo $results[0].Key > $logFile
    $msg.body += "downloading... " + $results[0].Key
    Read-S3Object -BucketName $bucketName -Key $results[0].Key -File $localFile
}
catch {
    echo "File Download Failed" > $logFile
    $msg.body += "File Download Failed: " + $_.Exception.Message
    $smtp.Send($msg)
    exit
}

$msg.body += "Download Completed"

#============================================================
# Restore a Database using PowerShell and SQL Server SMO
# Restore to the same database, overwrite existing db
#============================================================

#load assemblies
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null

#Need SmoExtended for backup
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null
 
#get backup file
#you can also use PowerShell to query the last backup file based on the timestamp
#I'll save that enhancement for later


$server = New-Object ("Microsoft.SqlServer.Management.Smo.Server") "(local)"
$backupDevice = New-Object ("Microsoft.SqlServer.Management.Smo.BackupDeviceItem") ($backupFile, "File")
$smoRestore = new-object("Microsoft.SqlServer.Management.Smo.Restore")

#settings for restore
$smoRestore.ReplaceDatabase = $TRUE;
$smoRestore.Action = [Microsoft.SqlServer.Management.Smo.RestoreActionType]::Database

$smoRestore.PercentCompleteNotification = 10;

$smoRestore.Devices.Add($backupDevice)
 
#read db name from the backup file's backup header
$smoRestoreDetails = $smoRestore.ReadBackupHeader($server)

# get db name
$dbName = $smoRestoreDetails.Rows[0]["DatabaseName"]
$smoRestore.Database = $dbName

"Restoring database... " + $dbName
$msg.body += "Restoring database... " + $dbName

try {
    echo "drop database" > $logFile
    #drop the database
    $server.KillDatabase($dbName)
    #restore
    echo "restore database" > $logFile
    $smoRestore.SqlRestore($server)
}
catch [exception] {
    echo "Restore Database Failed" > $logFile
    $msg.body += "Restore Database Failed: " + $_.Exception.Message
    $smtp.Send($msg)
    exit
}


#============================================================
# Senatise database
#============================================================
$msg.body += "Senatise database..."
$script = ".\senatise_bng.sql";
$sql = gc $script

try {
    echo "senatise database" > $logFile
    sqlcmd -Q ("USE " + $dbName + ";" + $sql)
}
catch [exception] {
    echo "Senatise Database Failed" > $logFile
    $msg.body += "Senatise Database Failed: " + $_.Exception.Message
    $smtp.Send($msg)
    exit
}

echo "Done" > $logFile
$msg.body += "Done"
$smtp.Send($msg)
"Done"
