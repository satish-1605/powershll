

# to avoid if someone is creating resources by PS
Disable-AzContextAutosave

$subscriptionname= "Azure Pass - Sponsorship"
$subscription= Get-AzSubscription -SubscriptionName $subscriptionname
Set-AzContext -SubscriptionObject $subscription

New-AzResourceGroup -Name "powershell-RG" -Location "EAST US"

Connect-AzAccount

New-AzResourceGroup -Name $RG -Location $location

$Accountname= "satishstorage06481595"
$accounttype="StorageV2"
$AccountSKU= "Standard_LRS"
$RG=  "powershell-RG1"
$location= "EAST US"

$storageaccount= New-AzStorageAccount -ResourceGroupName $RG -Name $Accountname `
-SkuName $AccountSKU -Location $location -Kind $accounttype

$storageaccount