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

    $NetworkInterfaces=New-AzNetworkInterface -Name "$NetworkInterfaceName" `
    -ResourceGroupName $ResourceGroupName -Location $Location `
    -Subnet $Subnet    


 
# Creating the Public IP Addresss

$PublicIPAddressName="app-ip"

$PublicIPAddresses=New-AzPublicIpAddress -Name "$PublicIPAddressName$i" -ResourceGroupName $ResourceGroupName `
-Location $Location -Sku "Standard" -AllocationMethod "Static"

$IpConfigs=Get-AzNetworkInterfaceIpConfig -NetworkInterface $NetworkInterfaces

$NetworkInterfaces | Set-AzNetworkInterfaceIpConfig -PublicIpAddress $PublicIPAddresses`
-Name $IpConfigs.Name

$NetworkInterfaces | Set-AzNetworkInterface

# Creating the Network Security Group

$SecurityRule1=New-AzNetworkSecurityRuleConfig -Name "Allow-RDP" -Description "Allow-RDP" `
-Access Allow -Protocol Tcp -Direction Inbound -Priority 100 `
-SourceAddressPrefix * -SourcePortRange * `
-DestinationAddressPrefix * -DestinationPortRange 3389

$NetworkSecurityGroupName="app-nsg"

$NetworkSecurityGroup=New-AzNetworkSecurityGroup -Name $NetworkSecurityGroupName `
-ResourceGroupName $ResourceGroupName -Location $Location `
-SecurityRules $SecurityRule1

$VirtualNetworkName="app-network"
$SubnetName="SubnetA"
$SubnetAddressSpace="10.0.0.0/24"

$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

Set-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork `
-NetworkSecurityGroup $NetworkSecurityGroup `
-AddressPrefix $SubnetAddressSpace

$VirtualNetwork | Set-AzVirtualNetwork

<#
#creating azure key vault
$keyvaultname= "app-keyvault1218275"
$ResourceGroupName ="powershell-grp"
$Location="North Europe"
New-AzKeyVault -Name $keyvaultname -ResourceGroupName $ResourceGroupName -Location $Location `
-SoftDeleteRetentionInDays 7
#Giving accces to Powershell named object in keyvault
$ObjectID= "9d204913-2a5d-4889-a65c-e2f0220656e0"
Set-AzKeyVaultAccessPolicy -VaultName $keyvaultname -ResourceGroupName $ResourceGroupName `
-ObjectId $ObjectID -PermissionsToSecrets get,set


#password once kept secret will not be used again so can be deleted
$secretvault= ConvertTo-SecureString -string "Azure@123" -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $keyvaultname -name "vmpassword" -SecretValue $secretvault 
#>

# Creating the Azure Virtual Machine

$VmName="appvm"
$VMSize = "Standard_D2as_v4"

$Location ="North Europe"
$UserName="demousr"
$Password= Get-AzKeyVaultSecret -VaultName $keyvaultname -name "vmpassword" -AsPlainText

$PasswordSecure=ConvertTo-SecureString -String $Password -AsPlainText -Force

$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $UserName,$PasswordSecure


$NetworkInterfaces= Get-AzNetworkInterface -Name "$NetworkInterfaceName" -ResourceGroupName $ResourceGroupName

$VmConfig+=New-AzVMConfig -Name "$VmName" -VMSize $VMSize

Set-AzVMOperatingSystem -VM $VmConfig -ComputerName "$VmName" `
-Credential $Credential -Windows

Set-AzVMSourceImage -VM $VmConfig -PublisherName "MicrosoftWindowsServer" `
-Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest"

$VMs+=Add-AzVMNetworkInterface -VM $VmConfig -Id $NetworkInterfaces.Id

Set-AzVMBootDiagnostic -Disable -VM $Vms

New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location `
-VM $VMs




