
# We need to give our service principal Contributor access at the Subscription Level
# This allows to add the Network Interfaces to the backend address pool of the Azure Application Gateway
# First we need to create a seperate subnet for the Application Gateway

$VirtualNetworkName="app-network"
$ResourceGroupName="powershell-grp"
$appgatewaysubnetname="AppGatewaySubnet"
$appgatewaysubnetaddspace= "10.0.1.0/24"

$VirtualNetwork= Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $ResourceGroupName

Add-AzVirtualNetworkSubnetConfig -Name $appgatewaysubnetname -VirtualNetwork $VirtualNetwork `
-AddressPrefix $appgatewaysubnetaddspace 

$VirtualNetwork | Set-AzVirtualNetwork 

# We also need a public IP Address that is going to be assigned to the Azure Application Gateway
$publicipdetails=@{
Name ='gateway-pip'
Location =$Location
sku= 'Standard'
AllocationMethod='Static'
ResourceGroupName=$ResourceGroupName

}
$PublicIP=New-AzPublicIpAddress @PublicIPDetails

#First is associating the gateway to the subnet
$appgatewayconfig=New-AzApplicationGatewayIPConfiguration -name "app-gatewayconfig" -Subnet $VirtualNetwork.Subnets[1]

# Then the FrontEnd IP Config
$PublicIP= get-AzPublicIpAddress -name $publicipdetails.Name -ResourceGroupName $ResourceGroupName 

$frontendip=New-AzApplicationGatewayFrontendIPConfig -name "frontend-gateway-ip" -PublicIPAddress $PublicIP 

# Then the FrontEnd port Config
$frontendport= New-AzApplicationGatewayFrontendPort -name "frontend-port" -Port 80

# Then we will create the BackendAddress Pool and the HTTP Setting
$NetworkInterface= Get-AzNetworkInterface -name "img-interface" -ResourceGroupName $ResourceGroupName 
$NetworkInterface.IpConfigurations[0].PrivateIpAddress

$Imagebackendpool= New-AzApplicationGatewayBackendAddressPool -Name "Imagebackendpool" `
-BackendIPAddresses $NetworkInterface.IpConfigurations[0].PrivateIpAddress  

$NetworkInterface= Get-AzNetworkInterface -name "vid-interface" -ResourceGroupName $ResourceGroupName 
$NetworkInterface.IpConfigurations[0].PrivateIpAddress

$videobackendpool= New-AzApplicationGatewayBackendAddressPool -Name "Videobackendpool" `
-BackendIPAddresses $NetworkInterface.IpConfigurations[0].PrivateIpAddress  
#HTTP Setting
$httpsetting= New-AzApplicationGatewayBackendHttpSetting -Name "Httpsetting" -Port 80 -Protocol Http `
-RequestTimeout 120 -CookieBasedAffinity Enabled
#Listener
$Listener=New-AzApplicationGatewayHttpListener -Name "listenerA" -Protocol Http `
-FrontendIPConfiguration $frontendip -FrontendPort $frontendport  

#rules
$Imagepathrule=New-AzApplicationGatewayPathRuleConfig  -name "Image-gatewayrule" -Paths "/images/*" `
-BackendAddressPool $Imagebackendpool -BackendHttpSettings $httpsetting  

$Videopathrule=New-AzApplicationGatewayPathRuleConfig  -name "Video-gatewayrule" -Paths "/videos/*" `
-BackendAddressPool $videobackendpool -BackendHttpSettings $httpsetting

$pathmapconfig= New-AzApplicationGatewayUrlPathMapConfig -Name "pathmapconfig" `
-PathRules $Imagepathrule,$Videopathrule -DefaultBackendAddressPool $Imagebackendpool `
-DefaultBackendHttpSettings $httpsetting 

$routingrule= New-AzApplicationGatewayRequestRoutingRule -Name "Routing-rule" -RuleType PathBasedRouting `
-HttpListener $Listener -UrlPathMap $pathmapconfig 

#gateway sku
$gatewaysku= New-AzApplicationGatewaySku -name Standard_v2 -Tier Standard_v2 -Capacity 2 

#finally creating appliction gateway
$ResourceGroupName="powershell-grp"
$Location= "North Europe"

new-azapplicationgateway -name "app-gateway1" -ResourceGroupName $ResourceGroupName -Location $Location `
-GatewayIPConfigurations $appgatewayconfig -FrontendPorts $frontendport -FrontendIPConfigurations $frontendip `
-BackendAddressPools $Imagebackendpool,$videobackendpool -BackendHttpSettingsCollection $httpsetting `
-HttpListeners $Listener -RequestRoutingRules $routingrule -Sku $gatewaysku -UrlPathMaps $pathmapconfig