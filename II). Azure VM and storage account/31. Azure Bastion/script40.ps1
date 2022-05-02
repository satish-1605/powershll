$ResourceGroupName ="powershell-grp"
$Location="North Europe"

$VirtualNetworkName="app-network"
$VirtualNetworkAddressSpace="10.0.0.0/16"
$SubnetName="SubnetA"
$SubnetAddressSpace="10.0.0.0/24"
$bastionSubnet= "AzureBastionSubnet"
$bastionsubnetaddspace= "10.0.2.0/24"

$Subnet=New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressSpace
#creating an azure bastion subnet
$bastionsubdetails=New-AzVirtualNetworkSubnetConfig -Name $bastionSubnet -AddressPrefix $bastionsubnetaddspace
# Creating the Virtual Network

$VirtualNetwork = New-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName `
-Location $Location -AddressPrefix $VirtualNetworkAddressSpace -Subnet $Subnet, $bastionsubdetails

Get-AzVirtualNetworkSubnetConfig  -VirtualNetwork $VirtualNetwork | Select-Object name

# remove the Public IP Addresss from nic

$NetworkInterfaces.IpConfigurations.PublicIpAddress.Id= $null
$NetworkInterfaces | set-azNetworkInterface

$PublicIPAddressName="app-ip1"

remove-AzPublicIpAddress -name $PublicIPAddressName -ResourceGroupName $ResourceGroupName -Force


$NetworkInterfaces= Get-AzNetworkInterface -name $NetworkInterfaceName -ResourceGroupName $ResourceGroupName


#create bastion IP
$PublicIPAddressName= "bastion-ip"
$ResourceGroupName ="powershell-grp"
$bastionSubnet= "AzureBastionSubnet"
$bastionsubnetaddspace= "10.0.2.0/24"
$publicipdetails= New-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -AllocationMethod Static `
-name $PublicIPAddressName -Location $Location -Sku "Standard" 

New-AzBastion -ResourceGroupName $ResourceGroupName -name "App-Bastion" -PublicIpAddress $publicipdetails `
-VirtualNetworkId $VirtualNetwork.Id



