

# run azconnect using a service principal

$appID= "496c905e-50ef-4406-9c34-7d197d43dce3"
$securesecret= $appsecret | ConvertTo-SecureString -AsPlainText -Force

$appsecret= "_s77Q~CSjUmqeggak3o_aiofrzMtEZwguQwcP"

$tenantID= "6580d9e6-c435-42f1-b7c7-dcc6e5fb06fa"

$credential = New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $appID,$securesecret

Connect-AzAccount -ServicePrincipal -Credential $credential -Tenant $tenantID

$RG=  "myRG"
Remove-AzResourceGroup $RG -Force
'removed resource group ' +$RG

#-----------------deleting all RGs
$allRG= Get-AzResourceGroup

foreach ($grp in $allRG) {
    'removing all the RGs' +$grp.ResourceGroupName
    Remove-AzResourceGroup -name $grp.ResourceGroupName -force

    
}