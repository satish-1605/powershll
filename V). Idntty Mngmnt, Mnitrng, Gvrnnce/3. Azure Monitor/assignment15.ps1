

#create alert for multiple VMs
$resourcegroupname = "powershell-grp"


$acctiongroup= Get-AzActionGroup -ResourceGroupName $resourcegroupname  


#creating alert for two VMs

$alertname= "CPUAlert"
$Threshold = 70
$metricname= "percentage CPU"
$Description= "Alert when CPU goes beyond 70"
$windowsize= New-TimeSpan -Minutes 5
$frequency= New-TimeSpan -Minutes 5

$condition= New-AzMetricAlertRuleV2Criteria -MetricName $metricname -TimeAggregation Average `
-Operator GreaterThanOrEqual -Threshold $Threshold 

 

    Add-AzMetricAlertRuleV2 -Name $alertname -ResourceGroupName $resourcegroupname -WindowSize $windowsize `
-Frequency $frequency  -Description $Description -TargetResourceScope "/subscriptions/0233b7e8-e787-4cdf-ae67-c12e56977b35" `
 -TargetResourceRegion "North Europe" -TargetResourceType "Microsoft.Compute/virtualMachines" `
-Condition $condition -Severity 3 -ActionGroupId $acctiongroup.Id


