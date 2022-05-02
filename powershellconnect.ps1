$appID= "f17115b1-f2f8-4cc1-9962-4518492b780e"
$securesecret= $appsecret | ConvertTo-SecureString -AsPlainText -Force

$appsecret= "UUv8Q~0y3rPqctWtMHuNryhKGyJ~tXdH.JVXJbmI"

$tenantID= "6580d9e6-c435-42f1-b7c7-dcc6e5fb06fa"

$credential = New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList $appID,$securesecret

Connect-AzAccount -ServicePrincipal -Credential $credential -Tenant $tenantID

