#List of all the role assignments


$resourcegroupname= "powershell-grp"
$subscription= Get-AzSubscription -SubscriptionName "Azure Pass - Sponsorship"
$scope= "/subscriptions/$subscription/resourcegroups/$resourcegroupname"


Get-AzRoleAssignment -Scope $scope