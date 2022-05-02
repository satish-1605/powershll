$ResourceGroupName ="powershell-grp"
$storageaccountname="storageaccount79839"

#Deny all traffic
Update-AzStorageAccountNetworkRuleSet -ResourceGroupName $ResourceGroupName -name $storageaccountname `
-DefaultAction Deny 

#add client ip address
$ipaddress= Invoke-WebRequest -Uri "https://ifconfig.me/ip" | Select-Object Content

Add-AzStorageAccountNetworkRule -ResourceGroupName $ResourceGroupName -Name $storageaccountname `
-IPAddressOrRange $ipaddress.Content 

$VirtualNetworkName= "app-network"
$virtualnetwork= Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName 

$subnetconfig= $virtualnetwork | Get-AzVirtualNetworkSubnetConfig


#add service endpoint and add virtual network
Set-AzVirtualNetworkSubnetConfig -name $subnetconfig[0].Name -VirtualNetwork $virtualnetwork `
-ServiceEndpoint "Microsoft.Storage" -AddressPrefix $subnetconfig[0].AddressPrefix | Set-AzVirtualNetwork

Add-AzStorageAccountNetworkRule -ResourceGroupName $ResourceGroupName -Name $storageaccountname `
-VirtualNetworkResourceId $subnetconfig[0].Id


