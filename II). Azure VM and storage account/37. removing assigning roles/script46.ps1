$ResourceGroupName ="powershell-grp"
$serviceprincipalname= "app-principal"
$serviceprincipal= Get-AzADServicePrincipal -DisplayName $serviceprincipalname 
$serviceprincipalID=$serviceprincipal.Id
$subscriptionname= "Azure_test"
$subscription= Get-AzSubscription -SubscriptionName $subscriptionname
# adding  role assignment at rG level
$scope= "/subscriptions/$subscription/resourcegroups/$ResourceGroupName"
$roledefinition= "Storage Account Contributor"

New-AzRoleAssignment -ObjectId $serviceprincipalID -RoleDefinitionName $roledefinition -Scope $scope

# remve role assignment at subscription level
$scope= "/subscriptions/$subscription"
$roledefinition= "Contributor"
$serviceprincipalID=$serviceprincipal.Id
Remove-AzRoleAssignment -ObjectId $serviceprincipalID -RoleDefinitionName $roledefinition -Scope $scope

Disable-AzContextAutosave
Disconnect-AzAccount