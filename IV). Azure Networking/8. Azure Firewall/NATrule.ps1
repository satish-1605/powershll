#creating DNAT rule
$MyIPAddress=Invoke-WebRequest -uri "https://ifconfig.me/ip" | Select-Object Content
$MyIPAddress.Content

$VmName="appvm"
# We need to get the private IP address assigned to appvm
$VMNetworkProfile=(Get-AzVm -Name $VmName).NetworkProfile
$NetworkInterface=Get-AzNetworkInterface -ResourceId $VMNetworkProfile.NetworkInterfaces[0].Id
$VMPrivateIPAddress=$NetworkInterface.IpConfigurations[0].PrivateIpAddress

$collectiongroup= New-AzFirewallPolicyRuleCollectionGroup -Name "NAtcollectiongrp" -Priority 200 `
-ResourceGroupName $ResourceGroupName -FirewallPolicyName "firewall-policy"  

$rule= New-AzFirewallPolicyNatRule -name "Allow-my-ip" -Protocol tcp  -SourceAddress $MyIPAddress.Content `
-DestinationAddress $FirewallPublicIP.IpAddress -DestinationPort "4000"  -TranslatedAddress $VMPrivateIPAddress `
-TranslatedPort 3389

$collection= New-AzFirewallPolicyNatRuleCollection -Name "NATcollection" -Priority 300 -Rule $rule `
-ActionType Dnat 

$collectiongroup= get-AzFirewallPolicyRuleCollectionGroup -Name "NAtcollectiongrp" `
-AzureFirewallPolicyName "firewall-policy" -ResourceGroupName $ResourceGroupName

$collectiongroup.Properties.RuleCollection.Add($collection)


# We then update the Firewall accordingly
$FirewallPolicy = Get-AzFirewallPolicy -Name "firewall-policy" -ResourceGroupName $ResourceGroupName

Set-AzFirewallPolicyRuleCollectionGroup -Name "NAtcollectiongrp" -Priority 200 `
-FirewallPolicyObject $FirewallPolicy -RuleCollection $CollectionGroup.Properties.RuleCollection `
