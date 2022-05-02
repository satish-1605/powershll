$ResourceGroupName="powershell-grp"
$location="North Europe"

#create PIP
$LBPIPdetail=@{

    Name="LB-pip"
    location=$location
    ResourceGroupName=$ResourceGroupName
    sku="Standard"
    AllocationMethod="Static"
}
$LBPIP= New-AzPublicIpAddress @LBPIPdetail

#create FE IP 
$FrontendIP= New-AzLoadBalancerFrontendIpConfig -Name "LB-FE-IP" -PublicIpAddress $LBPIP 

#create LB
$Loadbalancername= "app-Loadbalancer"
$LBDetail=New-AzLoadBalancer -ResourceGroupName $ResourceGroupName -Name $Loadbalancername -Sku "Standard" `
-FrontendIpConfiguration $FrontendIP -Location $location

#BAckend Pool 
$Backendpoolname="app-bepool"
$LBDetail= Get-AzLoadBalancer -ResourceGroupName $ResourceGroupName -name $Loadbalancername
$LBDetail | Add-AzLoadBalancerBackendAddressPoolConfig -name $Backendpoolname 
$LBDetail | Set-AzLoadBalancer
#assign VM to be pool

$NetworkInterfaces=@()
$NetworkInterfaces=Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName |  `
where-Object {$_.Name -like "app-interface*"} 

$Backendpool= Get-AzLoadBalancerBackendAddressPool -ResourceGroupName $ResourceGroupName `
-LoadBalancerName $Loadbalancername -name $Backendpoolname

foreach($nic in $NetworkInterfaces)
{
    $nic.IpConfigurations[0].LoadBalancerBackendAddressPools= $Backendpool
    $nic |Set-AzNetworkInterface
}

#adding Health Probe
Add-AzLoadBalancerProbeConfig -LoadBalancer $LBDetail -name "LB-health" -port 80 -Protocol tcp `
-IntervalInSeconds 10 -ProbeCount 2

$LBDetail | Set-AzLoadBalancer

$probe= get-AzLoadBalancerProbeConfig -LoadBalancer $LBDetail -name "LB-health"

#LB rule
Add-AzLoadBalancerRuleConfig -LoadBalancer $LBDetail -name "LBrule" -Protocol tcp `
-FrontendIpConfiguration $LBDetail.FrontendIpConfigurations[0] -FrontendPort 80 -BackendPort 80 `
-BackendAddressPool $LBDetail.BackendAddressPools -Probe $probe

$LBDetail | Set-AzLoadBalancer