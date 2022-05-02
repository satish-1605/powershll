$ResourceGrpname ="myRG"
$VmName="appvm"
$resizedOSdisk= "Standard_D4as_v4"

$vmdetails= Get-AzVM -ResourceGroupName $ResourceGrpname -Name $VmName 

$vmdetails.HardwareProfile.VmSize =$resizedOSdisk
$vmdetails | Update-AzVM