#--------------------creating VNET-------------------------
#Ask the user how many machines are we going to use
param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateRange(1,4)]
    [Int32]
    $Numberofmachines
)

# Creating the Network Interface
$ResourceGroupName="powershell-grp"
$VirtualNetworkName="app-network"
$VirtualNetwork= Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName
$subnetconfig= $VirtualNetwork | Get-AzVirtualNetworkSubnetConfig

$NetworkInterfaceName="app-interface"
$NetworkInterfaces=@()

for($i=1;$i -le $Numberofmachines; $i++)
{
    $NetworkInterfaces+=New-AzNetworkInterface -Name "$NetworkInterfaceName$i" `
    -ResourceGroupName $ResourceGroupName -Location $Location `
    -Subnet $subnetconfig[0]    
}

 

# Creating the Network Security Group
$SecurityRule1=New-AzNetworkSecurityRuleConfig -Name "Allow-RDP" -Description "Allow-RDP" `
-Access Allow -Protocol Tcp -Direction Inbound -Priority 100 `
-SourceAddressPrefix * -SourcePortRange * `
-DestinationAddressPrefix * -DestinationPortRange 3389

$SecurityRule2=New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Description "Allow-HTTP" `
-Access Allow -Protocol Tcp -Direction Inbound -Priority 200 `
-SourceAddressPrefix * -SourcePortRange * `
-DestinationAddressPrefix * -DestinationPortRange 80

$NetworkSecurityGroupName="app-nsg"
$Location="North Europe"

$NetworkSecurityGroup=New-AzNetworkSecurityGroup -Name $NetworkSecurityGroupName `
-ResourceGroupName $ResourceGroupName -Location $Location `
-SecurityRules $SecurityRule1, $SecurityRule2

$VirtualNetworkName="app-network"
$SubnetName="SubnetA"
$SubnetAddressSpace="10.0.0.0/24"

$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

Set-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork `
-NetworkSecurityGroup $NetworkSecurityGroup `
-AddressPrefix $SubnetAddressSpace

$VirtualNetwork | Set-AzVirtualNetwork

# Creating the Azure Virtual Machine

$VmName="appvm"
$VMSize = "Standard_D2as_v4"

$Location ="North Europe"
$UserName="demousr"
$Password="Azure@123"

$PasswordSecure=ConvertTo-SecureString -String $Password -AsPlainText -Force

$Credential = New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $UserName,$PasswordSecure

$VmConfig=@()
$VMs=@()

for($i=1;$i -le $Numberofmachines;$i++)
{

$NetworkInterfaces[$i-1]= Get-AzNetworkInterface -Name "$NetworkInterfaceName$i" -ResourceGroupName $ResourceGroupName

$VmConfig+=New-AzVMConfig -Name "$VmName$i" -VMSize $VMSize

Set-AzVMOperatingSystem -VM $VmConfig[$i-1] -ComputerName "$VmName$i" `
-Credential $Credential -Windows

Set-AzVMSourceImage -VM $VmConfig[$i-1] -PublisherName "MicrosoftWindowsServer" `
-Offer "WindowsServer" -Skus "2019-Datacenter" -Version "latest"

$VMs+=Add-AzVMNetworkInterface -VM $VmConfig[$i-1]  -Id $NetworkInterfaces[$i-1].Id

Set-AzVMBootDiagnostic -Disable -VM $Vms[$i-1]

New-AzVM -ResourceGroupName $ResourceGroupName -Location $Location `
-VM $VMs[$i-1]

}


