$resourcegroupname ="myRG"
$location= "eastus2"
$servername= "sqlserver" + (new-guid).ToString().Substring(1,7)
$username= "sqladmin"
$password="Azure@123"
$databasename="mywebdb"

$passwordsecure= ConvertTo-SecureString -String $password -AsPlainText -Force
$credential= New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $username, $passwordsecure

New-AzSqlServer -ResourceGroupName $resourcegroupname -ServerName $servername `
-Location $location -SqlAdministratorCredentials $credential

New-AzSqlDatabase -ResourceGroupName $resourcegroupname -ServerName $servername -DatabaseName $databasename `
-RequestedServiceObjectiveName "Basic"

$ipaddress=Invoke-WebRequest -Uri "https://ifconfig.me/ip" | Select-Object Content
$ipaddress.Content

New-AzSqlServerFirewallRule -ResourceGroupName $resourcegroupname -ServerName $servername `
-FirewallRuleName "Allow-client" -StartIpAddress $ipaddress.Content -EndIpAddress $ipaddress.Content

#Get-AzSqlServerServiceObjective