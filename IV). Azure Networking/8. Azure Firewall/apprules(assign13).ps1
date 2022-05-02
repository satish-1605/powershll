$appcollectiongroup= New-AzFirewallPolicyRuleCollectionGroup -Name "appcollectiongrp" `
-ResourceGroupName $ResourceGroupName -FirewallPolicyName "firewall-policy"  

$rule1= New-AzFirewallApplicationRule -name "allow google" -TargetFqdn "www.google.com" `
-Protocol https:443,http:80 -SourceAddress "10.0.0.4"  

$apprulecollection= New-AzFirewallPolicyFilterRuleCollection -name "apprulecollection" -Priority 1000 `
-Rule $rule1 -ActionType Allow


$appcollectiongroup= get-azFirewallPolicyRuleCollectionGroup -Name "appcollectiongrp" `
-ResourceGroupName $ResourceGroupName -AzureFirewallPolicyName "firewall-policy"

$appcollectiongroup.Properties.RuleCollection.Add($apprulecollection)


# We then update the Firewall accordingly
$FirewallPolicy = Get-AzFirewallPolicy -Name "firewall-policy" -ResourceGroupName $ResourceGroupName

set-azFirewallPolicyRuleCollectionGroup -name "appcollectiongrp" -Priority 800 
-FirewallPolicyObject $FirewallPolicy -RuleCollection $appCollectionGroup.Properties.RuleCollection
