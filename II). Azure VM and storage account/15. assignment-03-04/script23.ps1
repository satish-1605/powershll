
$subnetname= "test-subnet"
$subnetprifix= "10.0.2.0/24"
$vnetname= "MyVirtualNetwork"
$RGname= "TestResourceGroup"

$virNetworkdetails = Get-AzVirtualNetwork -Name $vnetname -ResourceGroupName $RGname

Add-AzVirtualNetworkSubnetConfig -name $subnetname -VirtualNetwork $virNetworkdetails -AddressPrefix $subnetprifix 
$virNetworkdetails | Set-AzVirtualNetwork 


#Reading all the subnets in the virtua network


Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $virNetworkdetails | Select-Object name,AddressPrefix