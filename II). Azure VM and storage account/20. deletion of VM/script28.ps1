# 1.  Deletion of data disk
$VmName="appvm"
$ResourceGrpname ="myRG"


$vmdetails= Get-AzVm -ResourceGroupName $ResourceGrpname -Name $VmName

foreach($datadisk in $vmdetails.StorageProfile.DataDisks)
{
    #detach data disk from vm
    'removing data disk from VM ' +$datadisk.Name
Remove-AzVMDataDisk -vm $vmdetails -DataDiskNames $datadisk.Name
$vmdetails | Update-AzVM 

#delete data disk
Get-AzDisk -ResourceGroupName $ResourceGrpname -DiskName $datadisk.Name | Remove-AzDisk -Force

}
#2. deleting PUblic IP address

foreach($networkinterfac in $vmdetails.NetworkProfile.NetworkInterfaces)
{
    $interface= Get-AzNetworkInterface -ResourceId  $networkinterfac.Id
    $publiPIP= Get-AzResource -ResourceId $interface.IpConfigurations.PublicIpAddress.Id
    $publiPIP.name
#dissociate pip from nic
$interface.IpConfigurations.PublicIpAddress.Id= $null
$interface | set-azNetworkInterface

#deleting pip
    Remove-AzPublicIpAddress -name $publiPIP.Name -ResourceGroupName $ResourceGrpname -force
}

#3. Handle the OS disk
$osdisk= $vmdetails.StorageProfile.OsDisk

#4. deleting Azure VM
Remove-AzVM -ResourceGroupName $ResourceGrpname -Name $VmName -force

#5. deleting niC
$interface | Remove-AzNetworkInterface -Force

#6. deleting OS disk
Get-AzDisk -ResourceGroupName $ResourceGrpname -DiskName $osdisk.Name | Remove-AzDisk -force
