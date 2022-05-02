$ResourceGroupName ="powershell-grp"

$Trafficemngerprofile= Get-AzTrafficManagerProfile -ResourceGroupName $ResourceGroupName
$Trafficemngerprofile.RelativeDnsName
$url = "http://" + $Trafficemngerprofile.RelativeDnsName + ".trafficmanager.net"

$Availibilitycheck=Invoke-WebRequest -Uri $url
$Availibilitycheck.StatusCode

while ($Availibilitycheck.StatusCode -eq 200) {
    
    try {
        
'The service is running'
    Start-Sleep -Seconds 1
    $Availibilitycheck=Invoke-WebRequest -Uri $url
    $Availibilitycheck.StatusCode
    }

catch{
    'The service is down'
    'Service is down since' + (Get-Date).DateTime
    break
}
    

}