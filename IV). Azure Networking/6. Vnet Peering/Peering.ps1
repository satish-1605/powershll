<#
$VirtualNetwork= Get-AzVirtualNetwork
$vnet1name=$VirtualNetwork[0].Name
$VirtualNetwork1= Get-AzVirtualNetwork -Name $vnet1name -ResourceGroupName $ResourceGroupName

$VirtualNetwork= Get-AzVirtualNetwork
$vnet2name=$VirtualNetwork[1].Name
$VirtualNetwork2= Get-AzVirtualNetwork -Name $vnet2name -ResourceGroupName $ResourceGroupName


Add-AzVirtualNetworkPeering -Name "stage-test" -VirtualNetwork $VirtualNetwork1 `
-RemoteVirtualNetworkId $VirtualNetwork2.Id 

Add-AzVirtualNetworkPeering -Name "test-stage" -VirtualNetwork $VirtualNetwork2 `
-RemoteVirtualNetworkId $VirtualNetwork1.Id 
#>

$Networksname= "staging-network","test-network"
$Virtualnetwork=@{}
foreach ($vnetname in $Networksname) {
 
    $VirtualNetwork.Add($vnetname, (Get-AzVirtualNetwork -Name $vnetname))
   }
   Add-AzVirtualNetworkPeering -Name "stage-test" -VirtualNetwork $VirtualNetwork.'staging-network' `
   -RemoteVirtualNetworkId $VirtualNetwork.'test-network'.Id
   
   Add-AzVirtualNetworkPeering -Name "test-stage" -VirtualNetwork $VirtualNetwork.'test-network' `
   -RemoteVirtualNetworkId $VirtualNetwork.'staging-network'.Id 