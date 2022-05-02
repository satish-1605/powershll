$ResourceGroupName ="powershell-grp"
$diskname= "datadisk1"
$VmName="appvm1"

$vmdetails= Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName 
Get-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $diskname
Add-AzVmDataDisk -VM $vmdetails -name $diskname -DiskSizeInGB 8 -Lun 0 -CreateOption Empty 

$vmdetails |Update-AzVM

#uploading initialize script into container
$BlobObject=@{
    FileLocation="C:\InitializeDisk.ps1"
    ObjectName ="InitializeDisk.ps1"
}

$Blob=Set-AzStorageBlobContent -Context $StorageAccount.Context -Container $ContainerName `
-File $BlobObject.FileLocation -Blob $BlobObject.ObjectName

#custom script to initialize the disk and create the volume

$bloburi= @($Blob.ICloudBlob.Uri.AbsoluteUri)
$storageaccountkey= (get-azstorageaccountkey -ResourceGroupName $ResourceGroupName -AccountName $AccountName) `
| Where-Object{$_.KeyName -eq "Key1"}

$storageaccountkeyvalue=$storageaccountkey.Value

$settings=@{"fileuris"= $bloburi}

$protectedsettings=@{"Storageaccount"= $AccountName; "Storageaccountkeyvalue"= $storageaccountkeyvalue; `
"commandToExecute" ="powershell -ExecutionPolicy Unrestricted -File InitializeDisk.ps1"};

Set-AzVMExtension -ResourceGroupName $ResourceGroupName -VMName $VmName -Publisher "Microsoft.Compute" `
-Name "DiskVolumeFormation" -ExtensionType "CustomScriptExtension" -TypeHandlerVersion "1.10" `
-Settings $settings -ProtectedSettings $protectedsettings

Get-AzVMExtension -ResourceGroupName $ResourceGroupName -VMName $VmName |Select-Object Name

