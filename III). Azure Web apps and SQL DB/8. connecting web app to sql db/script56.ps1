# Ensure that Azure Services are allowed to connect to the database server

$ResourceGroupName="powershell-grp"
$ServerName="dbserver78e482"

New-AzSqlServerFirewallRule -ResourceGroupName $ResourceGroupName `
-ServerName $ServerName -FirewallRuleName "Allow-Web" `
-StartIpAddress "0.0.0.0" -EndIpAddress "0.0.0.0"
