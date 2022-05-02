#making API calls
#GET https://management.azure.com/subscriptions/{subscriptionId}/resources?api-version=2021-04-01

#contruct authorization
#create a Better token which alows us to make request to ARM
$appID= "b0c32521-5ff6-4443-87d5-36b01f07f92f"
$appsecret= "YYb8Q~iC~2JjQU-IAqhJUJhRCTutndNx2Tm2RdBu"


$tokenuri= "https://login.microsoftonline.com/6580d9e6-c435-42f1-b7c7-dcc6e5fb06fa/oauth2/token"
#oauth
$resource= "https://management.core.windows.net"
$bodyrequest= "grant_type=client_credentials&client_id=$appID&client_secret=$appsecret&resource=$resource"

$accesstoken= Invoke-RestMethod -Method Post -Uri $tokenuri -Body $bodyrequest `
-ContentType 'application/x-www-form-urlencoded'

#access tke is like an entry coupen to make request to ARM

#{"error":{"code":"AuthenticationFailed","message":"Authentication failed. 
#The 'Authorization' header is missing."}}

$Headers=@{}
$Headers.Add("Authorization","Bearer " + $accesstoken.access_token)

$subscriptionId="0233b7e8-e787-4cdf-ae67-c12e56977b35"
$RequestUri= "https://management.azure.com/subscriptions/$subscriptionId/resources?api-version=2021-04-01"

$Resourcerequest=Invoke-RestMethod -Uri $RequestUri -Method Get -Headers $Headers
$Resourcerequest.value