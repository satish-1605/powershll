#creating route table
$ResourceGroupName ="powershell-grp"
$Location="North Europe"
$routetable= New-AzRouteTable -ResourceGroupName $ResourceGroupName -Name "Firewallroutetable" `
-Location $Location -DisableBgpRoutePropagation

$firewallname ="app-firewall"
$firewall=Get-AzFirewall -Name $firewallname -ResourceGroupName $ResourceGroupName  
$firewallpvtipadd= $firewall.IpConfigurations[0].PrivateIPAddress

New-AzRouteConfig -Name "Firewallroute"  -AddressPrefix 0.0.0.0/0 -NextHopType VirtualAppliance `
-NextHopIpAddress $firewallpvtipadd | Set-AzRouteTable

$ResourceGroupName ="powershell-grp"
$VirtualNetworkName ="app-network"
$SubnetName="SubnetA"
$SubnetAddressSpace="10.0.0.0/24"
 $VirtualNetwork = Get-AzVirtualNetwork -name $VirtualNetworkName -ResourceGroupName $ResourceGroupName 

 Set-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork `
 -AddressPrefix $SubnetAddressSpace -RouteTable $routetable | Set-AzVirtualNetwork

