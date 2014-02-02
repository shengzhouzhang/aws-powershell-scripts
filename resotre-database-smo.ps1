#============================================================
# Restore a Database using PowerShell and SQL Server SMO
# Restore to the same database, with different location
#============================================================

backupFile = "C:\Testdb.bak"     #Back up file

#load assemblies
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null

#Need SmoExtended for backup
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
[Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null

$server = new-object Microsoft.SqlServer.Management.Smo.Server("(local)")
$server.ConnectionContext.SqlExecutionModes = [Microsoft.SqlServer.Management.Common.SqlExecutionModes]::executesql
$backupDevice = new-object Microsoft.SqlServer.management.Smo.BackupDeviceItem($backupFile, [Microsoft.SqlServer.Management.Smo.DeviceType]::File)
$smoRestore = new-object Microsoft.SqlServer.Management.Smo.Restore

#settings for restore
$smoRestore.ReplaceDatabase = $true
$smoRestore.NoRecovery = $false         #important! fixed stuck in restoring state.
$smoRestore.Action = [Microsoft.SqlServer.Management.Smo.RestoreActionType]::Database

$smoRestore.Devices.Add($backupDevice)

# get db name
$dbName = $smoRestore.ReadBackupHeader($server).Rows[0]["DatabaseName"]
$smoRestore.Database = $dbName

$newdb = new-object Microsoft.SqlServer.Management.Smo.RelocateFile
$newdb.LogicalFileName = $smoRestore.ReadFileList($server).Rows[0][0].ToString();
$newdb.LogicalFileName
$newdb.PhysicalFileName = "F:\Testdb.mdb"    #restore to diffierent location
$smoRestore.RelocateFiles.Add($newdb);

$newlog = new-object Microsoft.SqlServer.Management.Smo.RelocateFile
$newlog.LogicalFileName = $smoRestore.ReadFileList($server).Rows[1][0].ToString();
$newlog.LogicalFileName
$newlog.PhysicalFileName = "F:\Testdb_log.ldf" #restore to diffierent location
$smoRestore.RelocateFiles.Add($newlog);

#drop the database
"killing database... " + $dbName
$server.KillDatabase($dbName)

#restore
"Restoring database... " + $dbName
$smoRestore.SqlRestore($server)

"Done"
