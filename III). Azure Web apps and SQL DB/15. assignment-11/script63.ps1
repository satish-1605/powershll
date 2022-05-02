$resourcegroupname ="myRG"
$newdatabasename="appdatabase1"
Get-AzSqlServer -ResourceGroupName $resourcegroupname | Select-Object ServerName


new-AzSqlDatabase -ResourceGroupName $resourcegroupname -ServerName "sqlserver9ead779" -DatabaseName $newdatabasename -RequestedServiceObjectiveName "S0"



Get-AzSqlDatabase -ResourceGroupName $resourcegroupname -ServerName "sqlserver9ead779" | Select-Object DatabaseName
