#creating RG

$location= "North Europe"
$tag=@{

    "Created By" = "Satish Gangwar"
    "EmpId"= "1218275"
    "EmailID"= "satish@gmail.com"
}
New-AzResourceGroup -Name $ResourceGrpname -Location $location -tag $tag

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
$NICname= "mynicCard"
$nicdetails= New-AzNetworkInterface -Name $NICname -ResourceGroupName $ResourceGrpname -Location $location `
-Subnet $vnetdetails.Subnets[0]

$nicdetails= get-AzNetworkInterface -name $NICname -ResourceGroupName $ResourceGrpname 


#create PIP
$pipname= "myPulipIP"
$pipdetails =New-AzPublicIpAddress -ResourceGroupName $ResourceGrpname -name $pipname -Location $location -Sku "Standard" `
-AllocationMethod "static" -IpAddressVersion "IPv4"



#set PIP to nIC card
$Ipconfigdetail= Get-AzNetworkInterfaceIpConfig -NetworkInterface $nicdetails

Set-AzNetworkInterfaceIpConfig -Name $Ipconfigdetail.Name -NetworkInterface $nicdetails `
-PublicIpAddress $pipdetails


$nicdetails |set-azNetworkInterface

#create NSg and rule
$securityrule = "allow RDP"
$secruledesc= new-AzNetworkSecurityRuleConfig -name $securityrule -Description "allow RDP" -Protocol Tcp -SourcePortRange * `
-DestinationPortRange 3389 -SourceAddressPrefix * -DestinationAddressPrefix * -Direction Inbound `
-Priority 110 -Access Allow


$nsgname= "my-NSG"
$nsgdetails=new-AzNetworkSecurityGroup -name $nsgname -ResourceGroupName $ResourceGrpname -Location $location `
-SecurityRules $secruledesc

#set NSG to subnet
Set-AzVirtualNetworkSubnetConfig -name $subnetname -VirtualNetwork $vnetdetails -AddressPrefix `
$subnetaddspace -NetworkSecurityGroup $nsgdetails 
'nsg is attached'
$vnetdetails |Set-AzVirtualNetwork 


Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnetdetails -name $subnetname

#creating VM
$VmName="appvm"
$VMSize = "Standard_D2as_v4"
$ResourceGrpname ="myRG"
$location= "North Europe"
$UserName="demousr"
$Password="Azure@123"

$PasswordSecure=ConvertTo-SecureString -String $Password -AsPlainText -Force

$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $UserName,$PasswordSecure

$VmConfig=New-AzVMConfig -Name $VmName -VMSize $VMSize -AvailabilitySetId $avsetdetail.Id

Set-AzVMOperatingSystem -VM $VmConfig -ComputerName $VmName `
-Credential $Credential -Windows

Set-AzVMSourceImage -VM $VmConfig -PublisherName "MicrosoftWindowsServer" `
-Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest"

$Vm=Add-AzVMNetworkInterface -VM $VmConfig -Id $nicdetails.Id

Set-AzVMBootDiagnostic -Disable -VM $Vm

New-AzVM -ResourceGroupName $ResourceGrpname -Location $Location `
-VM $Vm