$resourcegroupname= "powershell-grp"
$Webappname="my-webapp-12000237"
$rule1= "Deny intermet traffice"

#Deny internet traffic to the web app
Add-AzWebAppAccessRestrictionRule -ResourceGroupName $resourcegroupname -WebAppName $Webappname `
-Priority 400 -IpAddress "0.0.0.0/0"  -Name $rule1 -Action Deny

#All internet traffic from cliennt IP  to the web app
$ipaddress=Invoke-WebRequest -uri "https://ifconfig.me/ip" | Select-Object Content 
$ipaddress.Content

$Workstationip= $ipaddress.Content + "/32"
Add-AzWebAppAccessRestrictionRule -ResourceGroupName $resourcegroupname -WebAppName $Webappname `
-Priority 300 -IpAddress $Workstationip  -Name "Allow client IP" -Action Allow