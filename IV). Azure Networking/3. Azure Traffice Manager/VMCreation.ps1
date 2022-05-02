$ResourceGroupName ="powershell-grp"
$Locations="North Europe","UK South"

$VirtualNetworkName="app-network1","app-network2"
$VirtualNetworkAddressSpace="10.0.0.0/16","10.1.0.0/16"
$SubnetName="SubnetA"
$SubnetAddressSpace="10.0.0.0/24","10.1.0.0/24"
$NetworkSecurityGroupName="app-nsg1","app-nsg2"

$NetworkInterfaceName="app-interface"

$i=1
$VirtualNetworks=@()
$NetworkInterfaces=@()
$PublicIPAddresses=@()
$IpConfig=@()

$VmName="appvm"
$VMSize = "Standard_DS2_v2"

$Location ="North Europe"
$UserName="demousr"
$Password="Azure@123"

$PasswordSecure=ConvertTo-SecureString -String $Password -AsPlainText -Force

$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $UserName,$PasswordSecure

$VmConfig=@()
$VMs=@()

foreach($Location in $Locations)
{

'Location ' +  $Location
$Subnet=New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressSpace[$i-1] -WarningAction silentlyContinue

'Creating the virtual network ' + $VirtualNetworkName[$i-1]

$VirtualNetworks+=New-AzVirtualNetwork -Name $VirtualNetworkName[$i-1] -ResourceGroupName $ResourceGroupName `
-Location $Location -AddressPrefix $VirtualNetworkAddressSpace[$i-1] -Subnet $Subnet

Get-AzVirtualNetwork -ResourceGroupName $ResourceGroupName -Name $VirtualNetworkName[$i-1]

$Subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetworks[$i-1]

# Creating the Network Interface
'Creating the network interface ' + "$NetworkInterfaceName$i"

    $NetworkInterfaces+=New-AzNetworkInterface -Name "$NetworkInterfaceName$i" `
    -ResourceGroupName $ResourceGroupName -Location $Location `
    -Subnet $Subnet    

# Creating the Public IP Addresss

$PublicIPAddressName="app-ip"

' Creating the public IP Address ' + "$PublicIPAddressName$i"
$PublicIPAddresses+=New-AzPublicIpAddress -Name "$PublicIPAddressName$i" -ResourceGroupName $ResourceGroupName `
-Location $Location -Sku "Standard" -AllocationMethod "Static" -WarningAction silentlyContinue

$IpConfig+=Get-AzNetworkInterfaceIpConfig -NetworkInterface $NetworkInterfaces[$i-1]

$NetworkInterfaces[$i-1] | Set-AzNetworkInterfaceIpConfig -PublicIpAddress $PublicIPAddresses[$i-1] `
-Name $IpConfig[$i-1].Name

$NetworkInterfaces[$i-1] | Set-AzNetworkInterface

# Creating the Network Security Group

$SecurityRule1=New-AzNetworkSecurityRuleConfig -Name "Allow-RDP" -Description "Allow-RDP" `
-Access Allow -Protocol Tcp -Direction Inbound -Priority 100 `
-SourceAddressPrefix * -SourcePortRange * `
-DestinationAddressPrefix * -DestinationPortRange 3389

$SecurityRule2=New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Description "Allow-HTTP" `
-Access Allow -Protocol Tcp -Direction Inbound -Priority 200 `
-SourceAddressPrefix * -SourcePortRange * `
-DestinationAddressPrefix * -DestinationPortRange 80


' Creating the Network Security Group ' + $NetworkSecurityGroupName[$i-1]
$NetworkSecurityGroup=New-AzNetworkSecurityGroup -Name $NetworkSecurityGroupName[$i-1]  `
-ResourceGroupName $ResourceGroupName -Location $Location `
-SecurityRules $SecurityRule1,$SecurityRule2

Set-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetworks[$i-1] `
-NetworkSecurityGroup $NetworkSecurityGroup `
-AddressPrefix $SubnetAddressSpace[$i-1] 

$VirtualNetworks[$i-1] | Set-AzVirtualNetwork

' Creating the Azure VMs '

$NetworkInterfaces[$i-1]= Get-AzNetworkInterface -Name "$NetworkInterfaceName$i" -ResourceGroupName $ResourceGroupName

$VmConfig+=New-AzVMConfig -Name "$VmName$i" -VMSize $VMSize

Set-AzVMOperatingSystem -VM $VmConfig[$i-1] -ComputerName "$VmName$i" `
-Credential $Credential -Windows

Set-AzVMSourceImage -VM $VmConfig[$i-1] -PublisherName "MicrosoftWindowsServer" `
-Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest"

$VMs+=Add-AzVMNetworkInterface -VM $VmConfig[$i-1] -Id $NetworkInterfaces[$i-1].Id

Set-AzVMBootDiagnostic -Disable -VM $VMs[$i-1]

New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location `
-VM $VMs[$i-1]

# Work with the Custom Script Extension
$AccountName = "scalesetstorage1218275"
$ContainerName="scripts"
$BlobName="IIS_Config.ps1"

$StorageAccount=Get-AzStorageAccount -ResourceGroupName $ResourceGroupName `
-Name $AccountName

$Blob=Get-AzStorageBlob -Context $StorageAccount.Context `
-Container $ContainerName -Blob $BlobName

$blobUri=@($Blob.ICloudBlob.Uri.AbsoluteUri)
$StorageAccountKey=(Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName `
-AccountName $AccountName) | Where-Object {$_.KeyName -eq "key1"}

$settings=@{"fileUris"=$blobUri}

$StorageAccountKeyValue=$StorageAccountKey.Value

$protectedSettings=@{"storageAccountName" = $AccountName;"storageAccountKey"= $StorageAccountKeyValue; `
"commandToExecute" ="powershell -ExecutionPolicy Unrestricted -File IIS_Config.ps1"};

Set-AzVmExtension -ResourceGroupName $ResourceGroupName -Location $Location `
-VMName $VMs[$i-1].Name -Name "IISExtension" -Publisher "Microsoft.Compute" `
-ExtensionType "CustomScriptExtension" -TypeHandlerVersion "1.10" `
-Settings $settings -ProtectedSettings $protectedSettings

$i++

}


