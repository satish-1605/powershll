function get-resourceid {
    param (
        [String] $resourcename
    )
    $resource= Get-AzResource -name $resourcename
    return $resource.Id
}

$resourcegroupname = "powershell-grp"
$actiongroupname= "Admingroup"
$receivername= "Emailadmin"
$receiveremail= "Satishkrgangwar2687@gmail.com"


$receiver= New-AzActionGroupReceiver -Name $receivername -EmailReceiver -EmailAddress  $receiveremail 

$acctiongroup= Set-AzActionGroup -ResourceGroupName $resourcegroupname -name $actiongroupname -Receiver $receiver `
-ShortName $actiongroupname

#create an alert
$resourcename= "appvm"
$alertname= "CPUAlert"
$Threshold = 70
$metricname= "percentage CPU"
$Description= "Alert when CPU goes beyond 70"
$windowsize= New-TimeSpan -Minutes 5
$frequency= New-TimeSpan -Minutes 5

$condition= New-AzMetricAlertRuleV2Criteria -MetricName $metricname -Threshold $Threshold `
-TimeAggregation Average -Operator GreaterThanOrEqual 

Add-AzMetricAlertRuleV2 -Name $alertname -ResourceGroupName $resourcegroupname -WindowSize $windowsize `
-Frequency $frequency -TargetResourceId (get-resourceid $resourcename) -Description $Description `
-Condition $condition -Severity 3 -ActionGroupId $acctiongroup.Id
