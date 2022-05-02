$resourcegroupname= "powershell-grp"
$location="eastus2"
$Webappname="my-webapp-12000237"
$appserviceplanname= "ASP-powershell-grp"


#creating app service plan
New-AzAppServicePlan -ResourceGroupName $resourcegroupname -Name $appserviceplanname -Location $location `
-NumberofWorkers 1

#creating web app
New-AzWebApp -ResourceGroupName $resourcegroupname -Name $Webappname -Location $location `
-AppServicePlan $appserviceplanname `



