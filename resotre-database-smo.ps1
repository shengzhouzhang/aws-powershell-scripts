#============================================================
# Restore a Database using PowerShell and sqlcmd
# to the same database, with different location
#============================================================

$backupFile = "C:\Testdb.bak"
$dbName = "Testdb"
$dblogicName = "Testdb"
$dbPath = "F:\Testdb.mdf"
$logLogicName = "Testdb_Log"
$logPath = "F:\Testdb_Log.ldf"


#drop & restore the database
"Restoring database... " + $dbName
#$smoRestore.SqlRestore($server)

$sql = "IF EXISTS(select * from sys.databases where name='" + $dbName + "') DROP DATABASE " + $dbName + ";
        RESTORE DATABASE RiskMan
        FROM DISK = '" + $backupFile + "'
        WITH MOVE '" + $dblogicName + "' TO '" + $dbPath + "',
            MOVE '" + $logLogicName + "' TO '" + $logPath + "',
            REPLACE,RECOVERY;"

$sql

sqlcmd -Q $sql

"Done"
