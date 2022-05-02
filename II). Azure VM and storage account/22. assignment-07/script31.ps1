$VmName="appvm"
$ResourceGrpname ="myRG"
$location= "North Europe"



$vmdetails = get-azVM -ResourceGroupName $ResourceGrpname -name $VmName 
$vmdetails | Update-AzVM 

$storageaccntname ="storageaccount16051995"
New-AzStorageAccount -ResourceGroupName $ResourceGrpname -name $storageaccntname -Location $location `
-kind "StorageV2" -SkuName "Standard_LRS"
$strgeaccntdetails = Get-AzStorageAccount -ResourceGroupName $ResourceGrpname
$strgeaccntdetails

Set-AzVMBootDiagnostic -VM $vmdetails -ResourceGroupName $ResourceGrpname `
-StorageAccountName $storageaccntname -Enable

Update-AzVM -ResourceGroupName $ResourceGrpname -VM $vmdetails
 
$status= $vmdetails.DiagnosticsProfile.BootDiagnostics
$status