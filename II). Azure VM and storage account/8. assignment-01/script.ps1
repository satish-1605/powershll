$appID= "496c905e-50ef-4406-9c34-7d197d43dce3"
$securesecret= $appsecret | ConvertTo-SecureString -AsPlainText -Force

$appsecret= "_s77Q~CSjUmqeggak3o_aiofrzMtEZwguQwcP"

$tenantID= "6580d9e6-c435-42f1-b7c7-dcc6e5fb06fa"

$credential = New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $appID,$securesecret

Connect-AzAccount -ServicePrincipal -Credential $credential -Tenant $tenantID

$Accountname= "stoargeaccnt"
$ResourceGrpname="myRG"
Get-AzStorageAccount -AccountName $Accountname -ResourceGroupName $ResourceGrpname

$container=@(
    'containera'
    'containerb'
    'containerc'
)
foreach ($con in $container) {
    
    New-AzStorageContainer -name $con -Permission Blob -Context $storageaccount.Context
}




