#attach data disk in VM1

$ResourceGroupName ="powershell-grp"
$diskname= "datadisk"
$VmName="appvm1"

$vmdetails1= Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName 
Get-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $diskname
Add-AzVmDataDisk -VM $vmdetails1 -name $diskname -DiskSizeInGB 8 -Lun 0 -CreateOption Empty 

$vmdetails1 |Update-AzVM

#detach data disk in VM1
Remove-AzVmDataDisk -VM $vmdetails1 -DataDiskNames $diskname 

$vmdetails2 |Update-AzVM

#attach data disk in VM2
$VmName2="appvm2"
$diskname= "datadisk"
$vmdetails2= Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName2 

Add-AzVmDataDisk -VM $vmdetails2 -name $diskname -DiskSizeInGB 8 -Lun 0 -CreateOption attach `
-ManagedDiskId $(Get-AzDisk -ResourceGroupName $ResourceGroupName -DiskName $diskname).Id

$vmdetails2 |Update-AzVM