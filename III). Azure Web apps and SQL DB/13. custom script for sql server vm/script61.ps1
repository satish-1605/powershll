#creating RG
$ResourceGrpname ="myRG"
$location= "eastus2"
$tag=@{

    "Created By" = "Satish Gangwar"
    "EmpId"= "1218275"
    "EmailID"= "satish@gmail.com"
}
New-AzResourceGroup -Name $ResourceGrpname -Location $location -tag $tag

#create subnet and vnet
$subnetname= "dbSubnet"
$subnetaddspace= "192.168.0.0/24"
$vnetname= "dbVNetwork"
$vnetaddspace= "192.168.0.0/16"

$subnetdetails=New-AzVirtualNetworkSubnetConfig -Name $subnetname -AddressPrefix $subnetaddspace

new-azvirtualnetwork -name $vnetname -ResourceGroupName $ResourceGrpname -Location $location -AddressPrefix `
$vnetaddspace -Subnet $subnetdetails

$vnetdetails= Get-azvirtualnetwork -name $vnetname -ResourceGroupName $ResourceGrpname 


#create NIC card
#Get-Command set*networksecurity*
$NICname= "dbnicCard"
$vnetdetails= Get-azvirtualnetwork -name $vnetname -ResourceGroupName $ResourceGrpname 
$nicdetails= New-AzNetworkInterface -Name $NICname -ResourceGroupName $ResourceGrpname -Location $location `
-Subnet $vnetdetails.Subnets[0]

$nicdetails= get-AzNetworkInterface -name $NICname -ResourceGroupName $ResourceGrpname 


#create PIP
$pipname= "dbPulipIP"
$pipdetails =New-AzPublicIpAddress -ResourceGroupName $ResourceGrpname -name $pipname -Location $location -Sku "Standard" `
-AllocationMethod "static" -IpAddressVersion "IPv4"



#set PIP to nIC card
$nicdetails= get-AzNetworkInterface -name $NICname -ResourceGroupName $ResourceGrpname
$Ipconfigdetail= Get-AzNetworkInterfaceIpConfig -NetworkInterface $nicdetails

Set-AzNetworkInterfaceIpConfig -Name $Ipconfigdetail.Name -NetworkInterface $nicdetails `
-PublicIpAddress $pipdetails


$nicdetails |set-azNetworkInterface

#create NSg and rule
$securityrule = "allow RDP"
$secruledesc= new-AzNetworkSecurityRuleConfig -name $securityrule -Description "allow RDP" -Protocol Tcp -SourcePortRange * `
-DestinationPortRange 3389 -SourceAddressPrefix * -DestinationAddressPrefix * -Direction Inbound `
-Priority 100 -Access Allow

$securityrule1 = "allow SQl"
$secruledesc= new-AzNetworkSecurityRuleConfig -name $securityrule1 -Description "allow SQL" -Protocol Tcp -SourcePortRange * `
-DestinationPortRange 1433 -SourceAddressPrefix * -DestinationAddressPrefix * -Direction Inbound `
-Priority 200 -Access Allow


$nsgname= "db-NSG"
$nsgdetails=new-AzNetworkSecurityGroup -name $nsgname -ResourceGroupName $ResourceGrpname -Location $location `
-SecurityRules $secruledesc

#set NSG to subnet
Set-AzVirtualNetworkSubnetConfig -name $subnetname -VirtualNetwork $vnetdetails -AddressPrefix `
$subnetaddspace -NetworkSecurityGroup $nsgdetails 
'nsg is attached'
$vnetdetails |Set-AzVirtualNetwork 


Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnetdetails -name $subnetname

#creating VM
$VmName="databasevm"
$VMSize = "Standard_D2as_v4"
$ResourceGrpname ="myRG"
$location= "eastus2"
$UserName="demousr"
$Password="Azure@123"

$PasswordSecure=ConvertTo-SecureString -String $Password -AsPlainText -Force

$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $UserName,$PasswordSecure

$VmConfig=New-AzVMConfig -Name $VmName -VMSize $VMSize

Set-AzVMOperatingSystem -VM $VmConfig -ComputerName $VmName `
-Credential $Credential -Windows

Set-AzVMSourceImage -VM $VmConfig -PublisherName "MicrosoftSQLServer" `
-Offer "sql2019-ws2019" -Skus "sqldev" -Version "latest"

$Vm=Add-AzVMNetworkInterface -VM $VmConfig -Id $nicdetails.Id

Set-AzVMBootDiagnostic -Disable -VM $Vm

New-AzVM -ResourceGroupName $ResourceGrpname -Location $Location `
-VM $Vm

# Then we need to set the Custom Script Extensions to execute our custom PowerShell script
$resourcegroupname ="myRG"
$Accountname= "storageaccount" + (new-guid).ToString().Substring(1,7)
$accounttype="StorageV2"
$AccountSKU= "Standard_LRS"
$location= "eastus2"


$storageaccount= New-AzStorageAccount -ResourceGroupName $resourcegroupname -Name $Accountname `
-SkuName $AccountSKU -Location $location -Kind $accounttype

$containername= "scripts"
New-AzStorageContainer -name $containername -Context $storageaccount.Context -Permission Blob

$blobobject=@{
Filelocation= "C:/initscipt.ps1"
objectname= "initscipt.ps1"
}
$blob=Set-AzStorageBlobContent -Context $storageaccount.Context -Container $containername `
-blob $blobobject.objectname -file $blobobject.Filelocation
$blobUri=@($Blob.ICloudBlob.Uri.AbsoluteUri)
$settings = @{"fileUris" = $blobUri}

$storagekey=Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -AccountName $AccountName  `
| Where-Object {$_.KeyName -eq "key1"}
$storagekey.Value

$protectedsettings=@{"storageAccountName" = $AccountName; "storageAccountKey" = $StorageAccountKeyValue; `
"commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File initscriptcript.ps1"};

$protectedSettings
Set-AzVMExtension -ResourceGroupName $ResourceGroupName -Location $Location `
-VMName $VMName -Name "ConfigureSQL" -Publisher "Microsoft.Compute" `
-ExtensionType "CustomScriptExtension" -TypeHandlerVersion "1.10" `
-Settings $settings -ProtectedSettings $protectedSettings
