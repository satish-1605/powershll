$resourcegroupname= "powershell-grp"
$Webappname="my-webapp-12000237"

$properties=@{
    repoURL="https://github.com/satish-1605/WebApplication3";
    branch="master";
    isManualIntegration="true";

}

Set-AzResource -ResourceGroupName $resourcegroupname -Properties $properties `
-ResourceType Microsoft.Web/sites/sourccontrols -ResourceName $Webappname/web -ApiVersion 2015-08-01 -Force -Debug

#Get-AzWebApp -ResourceGroupName $resourcegroupname -name $Webappname

