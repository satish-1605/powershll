#Creating empty subnet
$ResourceGroupName ="powershell-grp"
$VirtualNetworkName ="app-network"
$SubnetName="AzureFirewallSubnet"
$SubnetAddressSpace="10.0.1.0/24"

$VirtualNetwork= Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

Add-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VirtualNetwork `
-AddressPrefix $SubnetAddressSpace 

$VirtualNetwork | Set-AzVirtualNetwork 

# We also need a public IP Address that is going to be assigned to the Azure Firewall resource
$publicipdetails=@{
    Name ='firewall-pip'
    Location =$Location
    sku= 'Standard'
    AllocationMethod='Static'
    ResourceGroupName=$ResourceGroupName
    
    }
    $FirewallPublicIP=New-AzPublicIpAddress @PublicIPDetails

    # Now we need to deploy the Azure Firewall resource
$firewallname= "app-firewall"
$firewallpolicy = New-AzFirewallPolicy -name "firewall-policy" -ResourceGroupName $ResourceGroupName `
-Location $Location  

$FirewallPublicIP=Get-AzPublicIpAddress -Name $PublicIPDetails.Name

New-AzFirewall -name $firewallname -ResourceGroupName $ResourceGroupName -Location $Location `
-VirtualNetwork $VirtualNetwork  -PublicIpAddress $FirewallPublicIP -FirewallPolicyId $firewallpolicy.Id
    

