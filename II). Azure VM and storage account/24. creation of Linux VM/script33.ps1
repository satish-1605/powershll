#creating RG

$location= "North Europe"
$tag=@{

    "Created By" = "Satish Gangwar"
    "EmpId"= "1218275"
    "EmailID"= "satish@gmail.com"
}
New-AzResourceGroup -Name $ResourceGrpname -Location $location -tag $tag
Get-AzResourceGroup -Name $ResourceGrpname -Location $location -tag $tag

#create subnet and vnet
$subnetname= "frontendSubnet"
$subnetaddspace= "192.168.0.0/24"
$vnetname= "myVNetwork"
$vnetaddspace= "192.168.0.0/16"

$subnetdetails=New-AzVirtualNetworkSubnetConfig -Name $subnetname -AddressPrefix $subnetaddspace

new-azvirtualnetwork -name $vnetname -ResourceGroupName $ResourceGrpname -Location $location -AddressPrefix `
$vnetaddspace -Subnet $subnetdetails

$vnetdetails= Get-azvirtualnetwork -name $vnetname -ResourceGroupName $ResourceGrpname 

#create NIC card
#Get-Command set*networksecurity*
$location= "North Europe"
$ResourceGrpname ="myRG"
$NICname= "mynic-linux"
$nicdetails= New-AzNetworkInterface -Name $NICname -ResourceGroupName $ResourceGrpname -Location $location `
-Subnet $vnetdetails.Subnets[0]

$nicdetails= get-AzNetworkInterface -name $NICname -ResourceGroupName $ResourceGrpname 


#create PIP
$pipname= "myPip-linux"
$pipdetails =New-AzPublicIpAddress -ResourceGroupName $ResourceGrpname -name $pipname -Location $location -Sku "Standard" `
-AllocationMethod "static" -IpAddressVersion "IPv4"

get-AzPublicIpAddress  -ResourceGroupName $ResourceGrpname | Select-Object name 


#set PIP to nIC card
$Ipconfigdetail= Get-AzNetworkInterfaceIpConfig -NetworkInterface $nicdetails

Set-AzNetworkInterfaceIpConfig -Name $Ipconfigdetail.Name -NetworkInterface $nicdetails `
-PublicIpAddress $pipdetails


$nicdetails |set-azNetworkInterface


#create NSg and rule
$securityrule1 = "allow SSh"
$secruledesc= new-AzNetworkSecurityRuleConfig -name $securityrule1 -Description "allow SSH" -Protocol Tcp -SourcePortRange * `
-DestinationPortRange 22 -SourceAddressPrefix * -DestinationAddressPrefix * -Direction Inbound `
-Priority 100 -Access Allow


$nsgname= "linux-NSG"
$nsgdetails=new-AzNetworkSecurityGroup -name $nsgname -ResourceGroupName $ResourceGrpname -Location $location `
-SecurityRules $secruledesc

#set NSG to subnet
Set-AzVirtualNetworkSubnetConfig -name $subnetname -VirtualNetwork $vnetdetails -AddressPrefix `
$subnetaddspace -NetworkSecurityGroup $nsgdetails 
'nsg is attached'
$vnetdetails |Set-AzVirtualNetwork 


Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnetdetails -name $subnetname

#creating VM
$VmName="appvm-linux"
$VMSize = "Standard_D2as_v4"
$ResourceGrpname ="myRG"
$location= "North Europe"
$UserName="demousr"


$PasswordSecure=ConvertTo-SecureString ' ' -AsPlainText -Force

$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $UserName,$PasswordSecure

$VmConfig=New-AzVMConfig -Name $VmName -VMSize $VMSize

Set-AzVMOperatingSystem -VM $VmConfig -ComputerName $VmName `
-Credential $Credential -Linux -DisablePasswordAuthentication

Set-AzVMSourceImage -VM $VmConfig -PublisherName "Canonical" `
-Offer "UbuntuServer" -Skus "18.04-LTS" -Version "latest"

$Vm=Add-AzVMNetworkInterface -VM $VmConfig -Id $nicdetails.Id

Set-AzVMBootDiagnostic -Disable -VM $Vm

New-AzVM -ResourceGroupName $ResourceGrpname -Location $Location `
-VM $Vm -GenerateSshKey -SshKeyName "Linuxkey"

#Test-Connection -TargetName 40.112.68.171 -TcpPort 22