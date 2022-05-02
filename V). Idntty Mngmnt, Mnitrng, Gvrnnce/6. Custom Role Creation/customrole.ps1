Connect-AzAccount

$roledefinition= "Storage Account Contributor"

$role=Get-AzRoleDefinition -Name $roledefinition 
$role.Id= $null
$role.name= "Storage Account and Virtual Machine Contributor"
$role.Description= "Have access of creating vm and storage account"
$role.Actions.Add("Microsoft.Authorization/*/read")
$role.Actions.Add("Microsoft.Compute/virtualMachines/start/action")
$role.Actions.Add("Microsoft.Compute/virtualMachines/restart/action")

 $resourcegroupname= "powershell-grp"
 $subscription= Get-AzSubscription -SubscriptionName "Azure Pass - Sponsorship"
 $scope= "/subscriptions/$subscription/resourcegroups/$resourcegroupname"

 $role.AssignableScopes.Clear()
 $role.AssignableScopes.Add($scope)
 
 New-AzRoleDefinition -Role $role

 #assign a role to service principal

 $serviceprincipal= Get-AzADServicePrincipal | Where-Object {$_.DisplayName -like "powershell*"}
 $serviceprincipal.Id
 $customroledefname= "Storage Account and Virtual Machine Contributor"
 $customrole=get-AzRoleDefinition -name $customroledefname

 New-AzRoleAssignment -ObjectId $serviceprincipal.Id -RoleDefinitionId $customrole.Id -Scope $scope 