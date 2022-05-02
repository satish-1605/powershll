$resourcegroupname = "powershell-grp"
$actiongroupname= "Admingroup"

$acctiongroup= get-AzActionGroup -ResourceGroupName $resourcegroupname -Name $actiongroupname

$AlertName= "ActivityLogAlert"
$Location= "Global"
$subscription= Get-AzSubscription -SubscriptionName "Azure Pass - Sponsorship" 
$Scope= "/subscriptions/$subscription"
$conditions=@()
$conditions+=New-AzActivityLogAlertCondition -Field "Category"-Equal "Administrative" 
$conditions+=New-AzActivityLogAlertCondition -Field "OperationName" `
-Equal "Microsoft.Compute/virtualMachines/deallocate/action"

set-AzActivityLogAlert -Location $Location -name $AlertName -ResourceGroupName $resourcegroupname -Scope $Scope `
-Condition $conditions `
-Action (New-Object Microsoft.Azure.Management.Monitor.Models.ActivityLogAlertActionGroup $acctiongroup.Id) 