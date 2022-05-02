$ResourceGrpname= "myRG"
$location="North Europe"
$VNET= "myvirtualNetwork"
$subnet= "mySubnet"


$myVNet= Get-AzVirtualNetwork -name $VNET -ResourceGroupName $ResourceGrpname
$webSubnet= Get-AzVirtualNetworkSubnetConfig -Name $subnet -VirtualNetwork $myVNet

$NICcard= "NetworkInterface"

$craeteNIC= New-AzNetworkInterface -name $NICcard -ResourceGroupName $ResourceGrpname `
-Location $location -Subnet $webSubnet

$craeteNIC