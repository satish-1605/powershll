$resourcegroupname ="myRG"
$databasename="mywebdb"


Get-AzSqlServer -ResourceGroupName $resourcegroupname | Select-Object ServerName

$dbdeatils=Get-AzSqlDatabase -ResourceGroupName $resourcegroupname -ServerName "sqlserver9ead779" `
-DatabaseName $databasename
$dbdeatils.RequestedServiceObjectiveName

Get-AzSqlServerServiceObjective -Location "eastus2"

$dbdeatils.RequestedServiceObjectiveName="Basic"

Set-AzSqlDatabase -ResourceGroupName $resourcegroupname -ServerName "sqlserver9ead779" `
-DatabaseName $databasename -RequestedServiceObjectiveName $dbdeatils.RequestedServiceObjectiveName

Get-AzSqlServerServiceObjective -Location "eastus2"