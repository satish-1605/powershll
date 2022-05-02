#creating service principal
Disable-AzContextAutosave
Connect-AzAccount
$serviceprincipalname= "app-principal"
$serviceprincipal= New-AzADServicePrincipal -DisplayName $serviceprincipalname  
$serviceprincipalID= $serviceprincipal.Id
$serviceprincipalsecret= $serviceprincipal.PasswordCredentials.SecretText
$serviceprincipalID
$serviceprincipalsecret

#giving rbac role to service principal
$subscriptionname= "Azure_test"
$subscription= Get-AzSubscription -SubscriptionName $subscriptionname
$scope= "/subscriptions/$subscription"
$roledefinition= "Contributor"

New-AzRoleAssignment -ObjectId $serviceprincipalID -RoleDefinitionName $roledefinition -Scope $scope `
-Description "Providing contri role to service principal"
#-------------------------------------------
Disconnect-AzAccount
$appID= $serviceprincipal.Id
$securesecret= $serviceprincipalsecret | ConvertTo-SecureString -AsPlainText -Force

$tenantID= "6580d9e6-c435-42f1-b7c7-dcc6e5fb06fa"

$credential = New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $appID,$securesecret

Connect-AzAccount -ServicePrincipal -Credential $credential -Tenant $tenantID

New-AzResourceGroup -name "app-grp2" -Location "North Europe"

