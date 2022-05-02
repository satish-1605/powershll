#deleting NSG


$ResourceGrpname ="myRG"
$vnetname= "myVNetwork"



$vnetdetails= Get-AzVirtualNetwork -Name $vnetname -ResourceGroupName $ResourceGrpname
$nsgid= $vnetdetails.Subnets.NetworkSecurityGroup.Id
$lngth= $nsgid.Length

$postin= $nsgid.LastIndexOf('/')

$nsgname= $nsgid.Substring($postin+1, $lngth-$postin-1)
#detach NSg from subnet
$vnetdetails.Subnets[0].NetworkSecurityGroup =$null
$vnetdetails |Set-AzVirtualNetwork
#delete nSG
Remove-azNetworkSecurityGroup -name $nsgname -ResourceGroupName $ResourceGrpname -Force  



