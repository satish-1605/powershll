$location="North Europe"
$subnet= "mySubnet"
$subnetaddressSpace= "192.168.0.0/24"

#creating nSG rule
$securityrule1= New-AzNetworkSecurityRuleConfig -name "Allow RDP" -Description "allow RDP" -Protocol Tcp -SourceAddressPrefix * `
-SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389 -Priority 100 -Direction Inbound `
-Access Allow

#create NSG
$NSgroup= New-AzNetworkSecurityGroup -name "myNSG" -ResourceGroupName $ResourceGrpname -Location $location `
-SecurityRules $securityrule1

#attach to subnet
$VNET= "myvirtualNetwork"
$ResourceGrpname= "myRG"
$myVNet=Get-AzVirtualNetwork -Name $VNET -ResourceGroupName $ResourceGrpname

Set-AzVirtualNetworkSubnetConfig -name $subnet -VirtualNetwork $myVNet -AddressPrefix `
$subnetaddressSpace -NetworkSecurityGroup $NSgroup

$myVNet| set-azVirtualNetwork


