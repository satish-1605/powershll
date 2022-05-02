$resourcegroupname ="powershell-grp"


$sourcedatabasename="mywebdb"
$targetdbname="restoredDB"

$servername="sqlserver882b678"


$dbdetails=Get-AzSqlDatabase -ResourceGroupName $resourcegroupname -DatabaseName $sourcedatabasename -ServerName $servername
$dbdetails.ResourceId
$Restorepointtime=(Get-Date).AddMinutes(-30)

Restore-AzSqlDatabase -FromPointInTimeBackup -PointInTime $Restorepointtime `
-ResourceGroupName $resourcegroupname -ServerName $servername -TargetDatabaseName $targetdbname `
-ResourceId $dbdetails.ResourceId -Edition Standard -ServiceObjectiveName "S0"

get-date