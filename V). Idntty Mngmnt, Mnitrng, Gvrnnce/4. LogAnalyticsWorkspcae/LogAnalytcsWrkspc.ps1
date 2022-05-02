#Moving the logs of resources to alalytics workspace
$workspacename= "loganalytics1218"
$resourcegroupname= "powershell-grp"
$Location= "North Europe"

#create a workspace 
$workspace= New-AzOperationalInsightsWorkspace -ResourceGroupName $resourcegroupname -Name $workspacename `
-Location $Location 

#windows event logs
New-AzOperationalInsightsWindowsEventDataSource -ResourceGroupName $resourcegroupname `
-WorkspaceName $workspacename -EventLogName "Application" -CollectErrors -CollectWarnings `
-CollectInformation -Name "Application Event Logs"

$workspace= get-AzOperationalInsightsWorkspace -ResourceGroupName $resourcegroupname -name $workspacename
$workspaceid= $workspace.CustomerId
$publicsettings=@{"Workspaceid"= $workspaceid}

$workspacekey=(Get-AzOperationalInsightsWorkspaceSharedKeys -ResourceGroupName $resourcegroupname `
-Name $workspacename).PrimarySharedKey 
$ProtectedSettings=@{"Workspacekey"= $workspacekey}

#install extensions into Vms
$VMsname= "appvm", "appvm2"
foreach($Vmnme in $VMsname){
Set-AzVMExtension -ResourceGroupName $resourcegroupname -VMName $Vmnme `
-ExtensionName "MicrosoftMonitoringAgent" -Publisher "Microsoft.EnterpriseCloud.monitoring" `
-ExtensionType "MicrosoftMonitoringAgent" -TypeHandlerVersion 1.0 -Location $Location `
-Settings $publicsettings -ProtectedSettings $ProtectedSettings
}

