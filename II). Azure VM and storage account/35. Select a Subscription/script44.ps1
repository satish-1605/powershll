$appID= "496c905e-50ef-4406-9c34-7d197d43dce3"
$securesecret= $appsecret | ConvertTo-SecureString -AsPlainText -Force

$appsecret= "ab3fb358-d7f5-4b7b-a6be-e432dbb879d9"

$tenantID= "6580d9e6-c435-42f1-b7c7-dcc6e5fb06fa"

$credential = New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $appID,$securesecret

Connect-AzAccount -ServicePrincipal -Credential $credential -Tenant $tenantID

#choosing a new subscription 

$subscriptionname= "Azure Pass - Sponsorship"
$subscription= Get-AzSubscription -SubscriptionName $subscriptionname
Set-AzContext -SubscriptionObject $subscription

$Accountname= "satishstorage06481595"
$accounttype="StorageV2"
$AccountSKU= "Standard_LRS"
$RG="powershell-RG"
$location= "east US"

$storageaccount= New-AzStorageAccount -ResourceGroupName $RG -Name $Accountname `
-SkuName $AccountSKU -Location $location -Kind $accounttype

$storageaccount

