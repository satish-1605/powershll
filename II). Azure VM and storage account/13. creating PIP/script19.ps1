$ResourceGrpname= "myRG"
$location="North Europe"


$sku= "Standard"
$tier= "Regional"
$ipversion="IPv4"
$allocationmethod="static"
$pip= "publicIPAdd"

$myPIP = New-AzPublicIpAddress -ResourceGroupName $ResourceGrpname -Location $location -Sku $sku -tier $tier `
  -IpAddressVersion $ipversion -Name $pip -AllocationMethod $allocationmethod

  $myPIP

#attach PIP to the nIC
$NICcard= "NetworkInterface"

$getNIC= Get-AzNetworkInterface -name $NICcard -ResourceGroupName $ResourceGrpname
$ipconfig= Get-AzNetworkInterfaceIpConfig -NetworkInterface $getNIC 

$getNIC | Set-AzNetworkInterfaceIpConfig  -name $ipconfig.Name  -PublicIpAddress $myPIP

$getNIC | Set-AzNetworkInterface



  <#
$mypip=@{
name='mypublicIP'
ResourceGroupName='myRG'
Location = 'North Europe'
Sku='Standard'

IpAddressVersion ="IPv4"
AllocationMethod ="static"


}
New-AzPublicIpAddress @myPIP
#>