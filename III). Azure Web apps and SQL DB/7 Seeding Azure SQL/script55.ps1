$resourcegroupname ="powershell-grp"


$username= "sqladmin"
$password="Azure@123"

$databasename="mywebdb"
$serverFQDN=$null

$sqlserver=Get-AzSqlServer -ResourceGroupName $resourcegroupname

 foreach ($sqlsrver in $sqlserver) {
     if ($sqlsrver.ServerName.contains("sqlserver")) {
         
        $serverFQDN=$sqlsrver.FullyQualifiedDomainName
        'The server FQDN is - ' +$serverFQDN
     }
     
     }

 $scriptfile= "C:/init.sql"
Invoke-SqlCmd -ServerInstance $serverFQDN -Database $databasename -Username $username `
-password $password -inputFile $scriptfile

#Install-module -name SqlServer