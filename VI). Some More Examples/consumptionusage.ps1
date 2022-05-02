#Getting the consumption usage details
#$instancename= "appvm"
#Get-AzConsumptionUsageDetail -InstanceName $instancename -debug
#contruct authorization
#create a bearer token which alows us to make request to ARM
$appID= "b0c32521-5ff6-4443-87d5-36b01f07f92f"
$appsecret= "YYb8Q~iC~2JjQU-IAqhJUJhRCTutndNx2Tm2RdBu"
$tokenuri= "https://login.microsoftonline.com/6580d9e6-c435-42f1-b7c7-dcc6e5fb06fa/oauth2/token"
#oauth
$resource= "https://management.core.windows.net"
$bodyrequest= "grant_type=client_credentials&client_id=$appID&client_secret=$appsecret&resource=$resource"

$accesstoken= Invoke-RestMethod -Method Post -Uri $tokenuri -Body $bodyrequest `
-ContentType 'application/x-www-form-urlencoded'

#access tke is like an entry coupen to make request to ARM
$subscription= Get-AzSubscription -SubscriptionName "Azure Pass - Sponsorship"
 $scope= "/subscriptions/$subscription/"
$Headers=@{}
$Headers.Add("Authorization","Bearer " + $accesstoken.access_token)
$RequestUri= "https://management.azure.com/$scope/providers/Microsoft.Consumption/usageDetails?api-version=2021-10-01"

$Resourcerequest=Invoke-RestMethod -Uri $RequestUri -Method Get -Headers $Headers
$values=$Resourcerequest.value

#get the things which are of use
$resourceUsage=@()
$totalcost=0
foreach($value in $values)
{
    $Usage=[PSCustomObject]@{
        InstanceName = $Value.properties.instanceName
        MeterName= $Value.properties.meterName 
        CostinuSD= $Value.properties.CostinuSD
    }
    $totalcost+=[Math]::Round($Value.properties.CostinuSD, 2)
    $resourceUsage+=$Usage
}
"Total cost is $totalcost"
$resourceUsage | Export-Csv -Path "resourceUsage.csv"