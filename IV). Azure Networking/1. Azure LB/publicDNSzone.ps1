$ResourceGroupName ="powershell-grp"
$publicdnsname="satish.com"

$dnszone=New-AzDnsZone -name $publicdnsname -ResourceGroupName $ResourceGroupName 
foreach($nameserver in $dnszone.NameServers)
{
    $nameserver
}

$Loadbalancername= "app-Loadbalancer"
$LBDetail=Get-AzLoadBalancer -ResourceGroupName $ResourceGroupName -name $Loadbalancername

$pipiddetail= $LBDetail.FrontendIpConfigurations[0].PublicIpAddress.Id

$pipobect= Get-AzResource -ResourceId $pipiddetail
$publicipaddress= Get-AzPublicIpAddress -Name $pipobect.Name

New-AzDnsRecordSet -Name www -RecordType A -ZoneName $publicdnsname -ResourceGroupName $ResourceGroupName `
-Ttl 3600 -DnsRecords (New-AzDnsRecordConfig -Ipv4Address $publicipaddress.IpAddress )