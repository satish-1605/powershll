#Creating RG
$ResourceGroupName ="powershell-grp"
$location="eastus2"

New-AzResourceGroup -ResourceGroupName $ResourceGroupName -Location $location


#--------------------creating VNET-------------------------

$VirtualNetworkName="app-network"
$VirtualNetworkAddressSpace="10.0.0.0/16"
$SubnetName="SubnetA"
$SubnetAddressSpace="10.0.0.0/24"

# Create the subnet resource

$Subnet=New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressSpace

# Creating the Virtual Network

$VirtualNetwork = New-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName `
-Location $Location -AddressPrefix $VirtualNetworkAddressSpace -Subnet $Subnet

$Subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork

#-----------------------deploying LB
$PublicIPDetails=@{
    Name='load-ip'
    Location=$Location
    Sku='Standard'
    AllocationMethod='Static'
    ResourceGroupName=$ResourceGroupName
}

$PublicIP=New-AzPublicIpAddress @PublicIPDetails

$FrontEndIP=New-AzLoadBalancerFrontendIpConfig -Name "load-frontendip" `
-PublicIpAddress $PublicIP

$LoadBalancerName="app-balancer"

New-AzLoadBalancer -ResourceGroupName $ResourceGroupName -Name $LoadBalancerName `
-Location $Location -Sku "Standard" -FrontendIpConfiguration $FrontEndIP

# Backend Pool
$LoadBalancer=Get-AzLoadBalancer -ResourceGroupName $ResourceGroupName `
-Name $LoadBalancerName

$LoadBalancer | Add-AzLoadBalancerBackendAddressPoolConfig -Name "vmpool"

$LoadBalancer | Set-AzLoadBalancer

#------------Virtual Machine Scale Set
$scalesetname="app-scaleset"
$location="eastus2"
$scalesetsize="Standard_D2as_v4"
$username="demousr"
$password="Azure@123"

$securepassword= ConvertTo-SecureString -String $password -AsPlainText -Force
New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $securepassword

$LoadBalancer=Get-AzLoadBalancer -ResourceGroupName $ResourceGroupName `
-Name $LoadBalancerName
$backendpool= Get-AzLoadBalancerBackendAddressPool -ResourceGroupName $ResourceGroupName `
-LoadBalancerName $LoadBalancerName -name "vmpool"
$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

# We want to ensure that the Virtual Machine Scale Set backend IP Addresses of the 
# Virtual Machines are added to the backend pool of the Load Balancer

$vmssIPconfig=New-AzVmssIpConfig -Name "Ipconfig-scaleset" -SubnetId $VirtualNetwork.Subnets[0].Id -Primary `
-LoadBalancerBackendAddressPoolsId $backendpool[0].Id 
$vmssconfig= new-azvmssconfig -SkuName $scalesetsize -Location $location -UpgradePolicyMode Automatic `
-SkuCapacity 2 

Set-AzVmssStorageProfile $vmssconfig -ImageReferenceOffer WindowsServer -ImageReferenceSku 2019-Datacenter `
-ImageReferencePublisher MicrosoftWindowsServer -ImageReferenceVersion latest -OsDiskCreateOption "FromImage"

Set-AzVmssOsProfile $vmssconfig -ComputerNamePrefix "app" -AdminUsername $username `
-AdminPassword $securepassword 

Add-AzVmssNetworkInterfaceConfiguration -Name "network-config" -IpConfiguration $vmssIPconfig `
-VirtualMachineScaleSet $vmssconfig -Primary $true 

new-azvmss -ResourceGroupName $ResourceGroupName -VMScaleSetName $scalesetname `
-VirtualMachineScaleSet $vmssconfig

# Adding the Health Probe

$LoadBalancer=Get-AzLoadBalancer -ResourceGroupName $ResourceGroupName `
-Name $LoadBalancerName

$LoadBalancer | Add-AzLoadBalancerProbeConfig -Name "ProbeA" -Protocol "tcp" -Port "80" `
-IntervalInSeconds "10" -ProbeCount "2"

$LoadBalancer | Set-AzLoadBalancer

# Adding the Load Balancing Rule

$LoadBalancer=Get-AzLoadBalancer -ResourceGroupName $ResourceGroupName `
-Name $LoadBalancerName

$BackendAddressPool=Get-AzLoadBalancerBackendAddressPoolConfig -Name "vmpool" `
-LoadBalancer $LoadBalancer

$Probe=Get-AzLoadBalancerProbeConfig -Name "ProbeA" -LoadBalancer $LoadBalancer

$LoadBalancer | Add-AzLoadBalancerRuleConfig -Name "RuleA" -FrontendIpConfiguration $LoadBalancer.FrontendIpConfigurations[0] `
-Protocol "Tcp" -FrontendPort 80 -BackendPort 80 -BackendAddressPool $BackendAddressPool `
-Probe $Probe

$LoadBalancer | Set-AzLoadBalancer

# Work with the Custom Script Extension
$config=@{
"fileUris"=(,"https://scalesetstorage1218275.blob.core.windows.net/scripts/IIS_Config.ps1");
"commandToExecute" ="powershell -ExecutionPolicy Unrestricted -File IIS_Config.ps1"
}
$ScaleSetName="app-scaleset"
$VirtualMachineScaleSet=Get-AzVmss -ResourceGroupName $ResourceGroupName `
-VMScaleSetName $ScaleSetName

$VirtualMachineScaleSet= Add-AzVmssExtension -VirtualMachineScaleSet $VirtualMachineScaleSet `
-Name "WebScript" -Publisher "Microsoft.Compute" `
-Type "CustomScriptExtension" -TypeHandlerVersion 1.9 -Setting $config

Update-AzVmss -ResourceGroupName $ResourceGroupName -Name $ScaleSetName `
-VirtualMachineScaleSet $VirtualMachineScaleSet


# Then apply the Network Security Group

$ResourceGroupName ="powershell-grp"
$VirtualNetworkName="app-network"

$SecurityRule1=New-AzNetworkSecurityRuleConfig -Name "Allow-HTTP" -Description "Allow-HTTP" `
-Access Allow -Protocol Tcp -Direction Inbound -Priority 200 `
-SourceAddressPrefix * -SourcePortRange * `
-DestinationAddressPrefix * -DestinationPortRange 80

$NetworkSecurityGroupName="app-nsg"
$Location ="eastus2"

$NetworkSecurityGroup=New-AzNetworkSecurityGroup -Name $NetworkSecurityGroupName `
-ResourceGroupName $ResourceGroupName -Location $Location `
-SecurityRules $SecurityRule1

$VirtualNetworkName="app-network"
$SubnetName="SubnetA"
$SubnetAddressSpace="10.0.0.0/24"

$VirtualNetwork=Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

Set-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork `
-NetworkSecurityGroup $NetworkSecurityGroup `
-AddressPrefix $SubnetAddressSpace

$VirtualNetwork | Set-AzVirtualNetwork
