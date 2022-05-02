$resourcegroupname ="powershell-grp"
$location= "eastus2"

$databasename="mywebdb"


$sqlserver=Get-AzSqlServer -ResourceGroupName $resourcegroupname

 foreach ($sqlsrver in $sqlserver) {
     if ($sqlsrver.ServerName.contains("sqlserver")) {
         
        $serverName=$sqlsrver.ServerName
        'The server name is - ' +$serverName
     }
     
     }

$wrokspacename= "db-workspace290"
$loganalyticsWS= New-AzOperationalInsightsWorkspace -ResourceGroupName $resourcegroupname `
-name $wrokspacename -Location $location 

Set-AzSqlDatabaseAudit -ResourceGroupName $resourcegroupname -ServerName $serverName `
-DatabaseName $databasename -LogAnalyticsTargetState Enabled -WorkspaceResourceId $loganalyticsWS.ResourceId