# Creating the Images server

$VirtualNetworkName="app-network"
$ResourceGroupName="powershell-grp"

Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

# Getting the subnet configuration

$SubnetConfig = Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VirtualNetworkName `
| Get-AzVirtualNetworkSubnetConfig


$NetworkInterfaceName="vid-interface"

$NetworkInterface = New-AzNetworkInterface -Name $NetworkInterfaceName `
-ResourceGroupName $ResourceGroupName -Location $Location `
-Subnet $SubnetConfig[0]

# Then we create the Azure Virtual Machine

$VmName="videosvm"
$VMSize = "Standard_D2as_v4"

$Location ="North Europe"
$UserName="demousr"
$Password="Azure@123"

$PasswordSecure=ConvertTo-SecureString -String $Password -AsPlainText -Force

$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $UserName,$PasswordSecure

$NetworkInterfaceName="vid-interface"
$NetworkInterface= Get-AzNetworkInterface -Name $NetworkInterfaceName -ResourceGroupName $ResourceGroupName

$VmConfig=New-AzVMConfig -Name $VmName -VMSize $VMSize

Set-AzVMOperatingSystem -VM $VmConfig -ComputerName $VmName `
-Credential $Credential -Windows

Set-AzVMSourceImage -VM $VmConfig -PublisherName "MicrosoftWindowsServer" `
-Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest"

$Vm=Add-AzVMNetworkInterface -VM $VmConfig -Id $NetworkInterface.Id

Set-AzVMBootDiagnostic -Disable -VM $Vm

New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location `
-VM $Vm


$AccountName = "aagstorage1605"
$ContainerName="scripts"

$StorageAccount=Get-AzStorageAccount -ResourceGroupName $ResourceGroupName `
-Name $AccountName

$BlobName="IIS_Config_Video.ps1"
$Blob=Get-AzStorageBlob -Context $StorageAccount.Context `
-Container $ContainerName -Blob $BlobName

$blobUri=@($Blob.ICloudBlob.Uri.AbsoluteUri)
$StorageAccountKey=(Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName `
-AccountName $AccountName) | Where-Object {$_.KeyName -eq "key1"}

$settings=@{"fileUris"=$blobUri}

$StorageAccountKeyValue=$StorageAccountKey.Value

$protectedSettings=@{"storageAccountName" = $AccountName;"storageAccountKey"= $StorageAccountKeyValue; `
"commandToExecute" ="powershell -ExecutionPolicy Unrestricted -File IIS_Config_Video.ps1"};

Set-AzVmExtension -ResourceGroupName $ResourceGroupName -Location $Location `
-VMName $VmName -Name "IISExtension" -Publisher "Microsoft.Compute" `
-ExtensionType "CustomScriptExtension" -TypeHandlerVersion "1.10" `
-Settings $settings -ProtectedSettings $protectedSettings

