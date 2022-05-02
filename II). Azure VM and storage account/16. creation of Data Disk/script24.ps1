#creating data disk
$ResourceGrpname ="myRG"
$diskname= "datadisk"
$VmName="appvm"

$vmdetails= Get-AzVM -ResourceGroupName $ResourceGrpname -Name $VmName 

Add-AzVmDataDisk -VM $vmdetails -name $diskname -DiskSizeInGB 8 -Lun 0 -CreateOption Empty 

$vmdetails |Update-AzVM