$resourcegroupname= "powershell-grp"
$Webappname="my-webapp-12000237"



Set-AzWebApp -ResourceGroupName $resourcegroupname -name $Webappname -RequestTracingEnabled $true `
-HttpLoggingEnabled $true -DetailedErrorLoggingEnabled $true 


# to check the logs 
#https://my-webapp-12000237.scm.azurewebsites.net/api/dump