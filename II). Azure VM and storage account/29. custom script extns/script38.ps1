#creating multiple VMs
#creating RG
$ResourceGroupName ="powershell-grp"
$Location="North Europe"
$tag=@{

    "Created By" = "Satish Gangwar"
    "EmpId"= "1218275"
    "EmailID"= "satish@gmail.com"
}
New-AzResourceGroup -Name $ResourceGroupName -Location $Location -tag $tag
<#
Command Reference
All of the commands stay the same as previous scripts for creating an Azure VM

#>




$VirtualNetworkName="app-network"
$VirtualNetworkAddressSpace="10.0.0.0/16"
$SubnetName="SubnetA"
$SubnetAddressSpace="10.0.0.0/24"

# Create the subnet resource

$Subnet=New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressSpace

# Creating the Virtual Network

$VirtualNetwork = New-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName `
-Location $Location -AddressPrefix $VirtualNetworkAddressSpace -Subnet $Subnet

$Subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork

# Creating the Network Interface

$NetworkInterfaceName="app-interface"
$NetworkInterfaces=@()

for($i=1;$i -le 2;$i++)
{
    $NetworkInterfaces+=New-AzNetworkInterface -Name "$NetworkInterfaceName$i" `
    -ResourceGroupName $ResourceGroupName -Location $Location `
    -Subnet $Subnet    
}

 
# Creating the Public IP Addresss

$PublicIPAddressName="app-ip"
$PublicIPAddresses=@()
$IpConfigs=@()

for($i=1;$i -le 2;$i++)
{
$PublicIPAddresses+=New-AzPublicIpAddress -Name "$PublicIPAddressName$i" -ResourceGroupName $ResourceGroupName `
-Location $Location -Sku "Standard" -AllocationMethod "Static"

$IpConfigs+=Get-AzNetworkInterfaceIpConfig -NetworkInterface $NetworkInterfaces[$i-1]

$NetworkInterfaces[$i-1] | Set-AzNetworkInterfaceIpConfig -PublicIpAddress $PublicIPAddresses[$i-1] `
-Name $IpConfigs[$i-1].Name

$NetworkInterfaces[$i-1] | Set-AzNetworkInterface

}


# Creating the Network Security Group

$SecurityRule1=New-AzNetworkSecurityRuleConfig -Name "Allow-RDP" -Description "Allow-RDP" `
-Access Allow -Protocol Tcp -Direction Inbound -Priority 100 `
-SourceAddressPrefix * -SourcePortRange * `
-DestinationAddressPrefix * -DestinationPortRange 3389

$SecurityRule2=New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Description "Allow-HTTP" `
-Access Allow -Protocol Tcp -Direction Inbound -Priority 200 `
-SourceAddressPrefix * -SourcePortRange * `
-DestinationAddressPrefix * -DestinationPortRange 80

$NetworkSecurityGroupName="app-nsg"

$NetworkSecurityGroup=New-AzNetworkSecurityGroup -Name $NetworkSecurityGroupName `
-ResourceGroupName $ResourceGroupName -Location $Location `
-SecurityRules $SecurityRule1, $SecurityRule2

$VirtualNetworkName="app-network"
$SubnetName="SubnetA"
$SubnetAddressSpace="10.0.0.0/24"

$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

Set-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork `
-NetworkSecurityGroup $NetworkSecurityGroup `
-AddressPrefix $SubnetAddressSpace

$VirtualNetwork | Set-AzVirtualNetwork

# Creating the Azure Virtual Machine

$VmName="appvm"
$VMSize = "Standard_D2as_v4"

$Location ="North Europe"
$UserName="demousr"
$Password="Azure@123"

$PasswordSecure=ConvertTo-SecureString -String $Password -AsPlainText -Force

$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $UserName,$PasswordSecure

$VmConfig=@()
$VMs=@()

for($i=1;$i -le 2;$i++)
{

$NetworkInterfaces[$i-1]= Get-AzNetworkInterface -Name "$NetworkInterfaceName$i" -ResourceGroupName $ResourceGroupName

$VmConfig+=New-AzVMConfig -Name "$VmName$i" -VMSize $VMSize

Set-AzVMOperatingSystem -VM $VmConfig[$i-1] -ComputerName "$VmName$i" `
-Credential $Credential -Windows

Set-AzVMSourceImage -VM $VmConfig[$i-1] -PublisherName "MicrosoftWindowsServer" `
-Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest"

$VMs+=Add-AzVMNetworkInterface -VM $VmConfig[$i-1]  -Id $NetworkInterfaces[$i-1].Id

Set-AzVMBootDiagnostic -Disable -VM $Vms[$i-1]

New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location `
-VM $VMs[$i-1]

}

#creating stoarage account for storing iis config file
$AccountName = "storageaccount79839"
$AccountKind="StorageV2"
$AccountSKU="Standard_LRS"
$ResourceGroupName="powershell-grp"
$Location = "North Europe"

$StorageAccount = New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $AccountName `
-Location $Location -Kind $AccountKind -SkuName $AccountSKU

# First to create the container
$ContainerName="data"

New-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context `
-Permission Blob


$BlobObject=@{
    FileLocation="C:\IIS_Config.ps1"
    ObjectName ="IIS_Config.ps1"
}

Set-AzStorageBlobContent -Context $StorageAccount.Context -Container $ContainerName `
-File $BlobObject.FileLocation -Blob $BlobObject.ObjectName

$storageaccountkey= (get-azstorageaccountkey -ResourceGroupName $ResourceGroupName -AccountName $AccountName) `
| Where-Object{$_.KeyName -eq "Key1"}

$storageaccountkeyvalue=$storageaccountkey.Value


$protectedSettings=@{"storageAccountName" = $AccountName;"storageAccountKey"= $StorageAccountKeyValue; `
"commandToExecute" ="powershell -ExecutionPolicy Unrestricted -File IIS_Config.ps1"};

Set-AzVmExtension -ResourceGroupName $ResourceGroupName -Location $Location `
-VMName $VmName -Name "IISExtension" -Publisher "Microsoft.Compute" `
-ExtensionType "CustomScriptExtension" -TypeHandlerVersion "1.10" `
-Settings $settings -ProtectedSettings $protectedSettings
