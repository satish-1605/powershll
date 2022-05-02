
$ResourceGroupName ="powershell-grp"

$VMs=@()
$VMs=Get-AzVM -ResourceGroupName $ResourceGroupName `
| Where-Object {$_.Name -Like "appvm*"}

$NumberofMachines=$VMs.Count

# Work with the Custom Script Extension
$AccountName = "lbstrgeaccntc8a1"
$ContainerName="data"

$StorageAccount=Get-AzStorageAccount -ResourceGroupName $ResourceGroupName `
-Name $AccountName

$BlobName="IIS_Config.ps1"
$Blob=Get-AzStorageBlob -Context $StorageAccount.Context `
-Container $ContainerName -Blob $BlobName

$blobUri=@($Blob.ICloudBlob.Uri.AbsoluteUri)
$StorageAccountKey=(Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName `
-AccountName $AccountName) | Where-Object {$_.KeyName -eq "key1"}

$settings=@{"fileUris"=$blobUri}

$StorageAccountKeyValue=$StorageAccountKey.Value

$protectedSettings=@{"storageAccountName" = $AccountName;"storageAccountKey"= $StorageAccountKeyValue; `
"commandToExecute" ="powershell -ExecutionPolicy Unrestricted -File IIS_Config.ps1"};

for($i=1;$i -le $NumberofMachines;$i++)
{
Set-AzVmExtension -ResourceGroupName $ResourceGroupName -Location $Location `
-VMName $VMs[$i-1].Name -Name "IISExtension" -Publisher "Microsoft.Compute" `
-ExtensionType "CustomScriptExtension" -TypeHandlerVersion "1.10" `
-Settings $settings -ProtectedSettings $protectedSettings
}