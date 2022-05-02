$resourcegroupname= "powershell-grp"
$Webappname="my-webapp-12000237"
$appserviceplanname= "ASP-powershell-grp"

#scale up app service plan

Set-AzAppServicePlan -ResourceGroupName $resourcegroupname -name $appserviceplanname -Tier Standard

#add a slot
$slotname="Staging"

New-AzWebAppSlot -ResourceGroupName $resourcegroupname -Name $Webappname -Slot $slotname 


# We then deploy an application onto the Staging slot
# Ensure to use your own GitHub URL

$Properties =@{
    repoUrl="";
    branch="master";
    isManualIntegration="true";
}

Set-AzResource -ResourceGroupName $ResourceGroupName `
-Properties $Properties -ResourceType Microsoft.Web/sites/slots/sourcecontrols `
-ResourceName $WebAppName/$SlotName/web -ApiVersion 2015-08-01 -Force

# The following can be used to switch slots

$TargetSlot="production"

Switch-AzWebAppSlot -Name $WebAppName -ResourceGroupName $ResourceGroupName `
-SourceSlotName $SlotName -DestinationSlotName $TargetSlot