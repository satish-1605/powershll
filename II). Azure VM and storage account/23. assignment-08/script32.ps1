#attahing nsg to nic

$ResourceGrpname="myRG"
$VmName="appvm"


$nsgname= "my-NSG"
$nsgdetails=Get-AzNetworkSecurityGroup -name $nsgname -ResourceGroupName $ResourceGrpname 

$vmdetails= get-azVm -ResourceGroupName $ResourceGrpname -name $VmName

$nicID=$vmdetails.NetworkProfile.NetworkInterfaces[0].Id
 $nicname= Get-AzNetworkInterface -ResourceId $nicID

$nicname.NetworkSecurityGroup= $nsgdetails
$nicname | set-azNetworkInterface

#dissociate nsg from subnet

$vnetdetails.Subnets[0].NetworkSecurityGroup= $null
$vnetdetails | Set-AzVirtualNetwork





