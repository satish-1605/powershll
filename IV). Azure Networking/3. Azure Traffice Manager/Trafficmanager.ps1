$Trafficemngerprofilename= "app-profile1000"
$ResourceGroupName ="powershell-grp"

$Trafficemngerprofile= New-AzTrafficManagerProfile -name $Trafficemngerprofilename `
-ResourceGroupName $ResourceGroupName -TrafficRoutingMethod Priority -MonitorProtocol HTTP -MonitorPort 80 `
-MonitorPath "/" -Ttl 30 -RelativeDnsName "satish.com" 

$PublicIPAddresses=@()
$PublicIPAddresses= Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName `
| Where-Object {$_.Name -like "app*"}
$i=1
foreach($PublicIPAddress in $PublicIPAddresses)
{
    Add-AzTrafficManagerEndpointConfig -EndpointName "Endpoint$i" -TrafficManagerProfile $Trafficemngerprofile `
    -Type ExternalEndpoints -Target $PublicIPAddress.IpAddress -EndpointStatus Enabled -Priority $i 

    
Set-AzTrafficManagerProfile -TrafficManagerProfile $Trafficemngerprofile
$i++
}

