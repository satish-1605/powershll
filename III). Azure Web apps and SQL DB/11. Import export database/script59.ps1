#create a storage account to backup the database to import into another server
$resourcegroupname ="powershell-grp"
$Accountname= "storageaccount" + (new-guid).ToString().Substring(1,7)
$accounttype="StorageV2"
$AccountSKU= "Standard_LRS"
$location= "eastus2"


$storageaccount= New-AzStorageAccount -ResourceGroupName $resourcegroupname -Name $Accountname `
-SkuName $AccountSKU -Location $location -Kind $accounttype

$containername= "sqldbbackup"
$container= $null
$container=New-AzStorageContainer -name $containername -Context $storageaccount.Context -Permission Blob


$sourcedatabasename="mywebdb"
$sourceservername="sqlserver882b678"

$username= "sqladmin"
$password="Azure@123"
$passwordsecure= ConvertTo-SecureString -String $password -AsPlainText -Force
$credential= New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $username, $passwordsecure

$bloburi= $container.CloudBlobContainer.Uri.AbsoluteUri + "/sqlbackup.bacpac"

$storageaccountkey= (get-azstorageaccountkey -ResourceGroupName $resourcegroupname -AccountName $AccountName) `
| Where-Object{$_.KeyName -eq "Key1"}

$storageaccountkeyvalue=$storageaccountkey.Value

$databaseexport= New-AzSqlDatabaseExport -ResourceGroupName $resourcegroupname -ServerName $sourceservername `
-DatabaseName $sourcedatabasename -AdministratorLogin $username -AdministratorLoginPassword `
$passwordsecure -StorageKeyType StorageAccessKey -StorageKey $storageaccountkeyvalue -StorageUri $bloburi 

#to know the sttaus of export
Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $databaseexport.OperationStatusLink

#create the new sql db  to import the db to new server

$targetservername= "targetsql" + (new-guid).ToString().Substring(1,7)
New-AzSqlServer -ResourceGroupName $resourcegroupname -ServerName $targetservername `
-Location $location -SqlAdministratorCredentials $credential

$targetdbname="targetappdb"
New-AzSqlDatabase -ResourceGroupName $resourcegroupname -ServerName $targetservername -DatabaseName $targetdbname `
-RequestedServiceObjectiveName "Basic"

$ipaddress=Invoke-WebRequest -Uri "https://ifconfig.me/ip" | Select-Object Content
$ipaddress.Content

New-AzSqlServerFirewallRule -ResourceGroupName $resourcegroupname -ServerName $targetservername `
-FirewallRuleName "Allow-client" -StartIpAddress $ipaddress.Content -EndIpAddress $ipaddress.Content

New-AzSqlServerFirewallRule -ResourceGroupName $resourcegroupname -ServerName $targetservername `
-FirewallRuleName "Allow-azureservices" -StartIpAddress "0.0.0.0" -EndIpAddress "0.0.0.0"


#import the database from storage account to target database
$databaseimport= New-AzSqlDatabaseImport -ResourceGroupName $resourcegroupname -ServerName $targetservername `
-DatabaseName $targetservername -ServiceObjectiveName "S3" -Edition Standard -DatabaseMaxSizeBytes 268435456000 `
-AdministratorLogin $username -AdministratorLoginPassword $passwordsecure -StorageKeyType StorageAccessKey `
-StorageKey $storageaccountkeyvalue -StorageUri $bloburi 

#to know the sttaus of import
Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $databaseimport.OperationStatusLink