
  #remove  a role from user
  
  $UserPrincipalName= "VanyaG@hunneysingh24x7outlook.onmicrosoft.com"
  $user=Get-AzADUser -ObjectId $UserPrincipalName 

 $roledefname= "Storage Account Contributor"
  $role=get-AzRoleDefinition -name $roledefname

  $resourcegroupname= "powershell-grp"
 $subscription= Get-AzSubscription -SubscriptionName "Azure Pass - Sponsorship"
 $scope= "/subscriptions/$subscription/resourcegroups/$resourcegroupname"


  Remove-AzRoleAssignment -ObjectId $user.Id -RoleDefinitionId $role.Id `
  -Scope $scope
 
  #delete custom role 
  $UserPrincipalName= "VanyaG@hunneysingh24x7outlook.onmicrosoft.com"
  $user=Get-AzADUser -ObjectId $UserPrincipalName 
  Remove-AzADUser -ObjectId $UserPrincipalName