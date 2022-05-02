Connect-AzAccount

$username= "VanyaG"
$UserPrincipalName= "VanyaG@hunneysingh24x7outlook.onmicrosoft.com"
$password= "Azure@123"
$passwordsecure= ConvertTo-SecureString -String $password -AsPlainText -Force 

New-AzADUser -DisplayName $username -MailNickname $username `
-UserPrincipalName $UserPrincipalName -Password $passwordsecure 

#assign RBAC to user
$user=Get-AzADUser -ObjectId $UserPrincipalName 

$resourcegroupname= "powershell-grp"
 $subscription= Get-AzSubscription -SubscriptionName "Azure Pass - Sponsorship"
 $scope= "/subscriptions/$subscription/resourcegroups/$resourcegroupname"

 $customroledefname= "Storage Account Contributor"
 $customrole=get-AzRoleDefinition -name $customroledefname

 New-AzRoleAssignment -ObjectId $user.Id -RoleDefinitionId $customrole.Id -Scope $scope 