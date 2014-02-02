#============================================================
# Restore a Database using PowerShell and sqlcmd
# to the same database, with different location
#============================================================

$backupFile = "C:\Users\Shengzhou\Downloads\RiskMan_backup_2014_01_31_040004_0169014.bak"
$dbName = "RiskMan"
$dblogicName = "RiskMan"
$dbPath = "F:\RiskMan.mdf"
$logLogicName = "RiskMan_Log"
$logPath = "F:\RiskMan_Log.ldf"


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
