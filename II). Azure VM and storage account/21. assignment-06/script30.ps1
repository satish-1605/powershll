$ResourceGrpname ="myRG"
$VmName="appvm"
$location= "North Europe"
$vnetname= "myVNetwork"
$subnetname= "frontendSubnet"
#stopped VM
Stop-AzVM -ResourceGroupName $ResourceGrpname -name $VmName -force

#creating NIC 
$NIC= "Secondarynetinterface"

$vnetdetails = Get-azvirtualnetwork -name $vnetname -ResourceGroupName $ResourceGrpname
$subnetdetails= Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnetdetails -Name $subnetname
New-AzNetworkInterface -name $NIC -ResourceGroupName $ResourceGrpname -Location $location -Subnet $subnetdetails

# setting first nic as primary interface
$setprimary= $vmdetails.NetworkProfile.NetworkInterfaces[0].Primary= $true
'nic interface as been set tp primary' +$setprimary
#adding  to VM

$nicdetails = get-AzNetworkInterface -ResourceGroupName $ResourceGrpname -Name $NIC

$vmdetails = get-azvm -ResourceGroupName $ResourceGrpname -name $VmName 
Add-AzVMNetworkInterface -VM $vmdetails -id $nicdetails.id 

Update-AzVM -ResourceGroupName $ResourceGrpname -VM $vmdetails 

Start-AzVM -ResourceGroupName $ResourceGrpname -name $VmName
