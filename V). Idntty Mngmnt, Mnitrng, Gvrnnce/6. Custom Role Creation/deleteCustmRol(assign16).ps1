
  #remove  a role to service principal

  $serviceprincipal= Get-AzADServicePrincipal | Where-Object {$_.DisplayName -like "powershell*"}
  $serviceprincipal.Id
  $customroledefname= "Storage Account and Virtual Machine Contributor"
  $customrole=get-AzRoleDefinition -name $customroledefname

  $resourcegroupname= "powershell-grp"
 $subscription= Get-AzSubscription -SubscriptionName "Azure Pass - Sponsorship"
 $scope= "/subscriptions/$subscription/resourcegroups/$resourcegroupname"


  Remove-AzRoleAssignment -ObjectId $serviceprincipal.Id -RoleDefinitionId $customrole.Id `
  -Scope $scope
 
  #delete custom role 
  $customroledefname= "Storage Account and Virtual Machine Contributor"
  Remove-AzRoleDefinition -name $customroledefname -Scope $scope -Force

  <#
  #Delete the role

$CustomRoleDefinition="Storage And Virtual Machine Contributor"
$CustomRole=Get-AzRoleDefinition -Name $CustomRoleDefinition

# We first need to delete the role assignments

$RoleAssignments=Get-AzRoleAssignment -RoleDefinitionId $CustomRole.Id

foreach($RoleAssignment in $RoleAssignments)
{
    Remove-AzRoleAssignment -ObjectId $RoleAssignment.ObjectId -RoleDefinitionName $CustomRoleDefinition `
    -Scope $RoleAssignment.Scope
}

Remove-AzRoleDefinition -Id $CustomRole.Id -Force#>