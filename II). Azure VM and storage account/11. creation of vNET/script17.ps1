$ResourceGrpname= "myRG"
$location="North Europe"

$VNET= "myvirtualNetwork"
$VnetAddressSpace="192.168.0.0/16"
$subnet= "mySubnet"
$subnetaddressSpace= "192.168.0.0/24"

#creating Subnet
$webSubnet= New-AzVirtualNetworkSubnetConfig -name $subnet -AddressPrefix $subnetaddressSpace

#creating Vnet
$myVNet= New-AzVirtualNetwork -Name $VNET -ResourceGroupName $ResourceGrpname -Location $location `
-AddressPrefix $VnetAddressSpace -Subnet $webSubnet

'the details of virtual network is ' +$myVNet