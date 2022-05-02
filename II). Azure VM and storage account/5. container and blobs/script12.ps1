$appID= "496c905e-50ef-4406-9c34-7d197d43dce3"
$securesecret= $appsecret | ConvertTo-SecureString -AsPlainText -Force

$appsecret= "_s77Q~CSjUmqeggak3o_aiofrzMtEZwguQwcP"

$tenantID= "6580d9e6-c435-42f1-b7c7-dcc6e5fb06fa"

$credential = New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $appID,$securesecret

Connect-AzAccount -ServicePrincipal -Credential $credential -Tenant $tenantID

$Accountname= "satishstorage0648159"
$ResourceGrpname="myRG"


#create container
$container= "data"
$storageaccount= Get-AzStorageAccount -AccountName $Accountname -ResourceGroupName $ResourceGrpname
New-AzStorageContainer -Name $container -Context $storageaccount.Context -permission Blob

#upload a blob

$blobobject =@{
    Filelocation ="C:\Users\Satish Gangwar\Desktop\ps_exercise\sample.txt"
    objectname= ".\sample.txt"
}
Set-AzStorageBlobContent -Context $storageaccount.Context -Container $container 
-file $blobobject['Filelocation'] -blob $blobobject['objectname']


<# Set-AzStorageBlobContent -Context $storageaccount.Context -Container $container 
 -file $blobobject.Filelocation -blob $blobobject.objectname #>
