#GET Request

$functionURi="https://powershellfunction159.azurewebsites.net/api/storageaccount?code=O_a41VX08F2wU4jBnNx9TD_HvbcOu6DPVoWEr3LaiHX2AzFu7tuxjw=="

Invoke-RestMethod -Uri $functionURi -Method Get

#Post Request

$functionURi= "https://powershellfunction159.azurewebsites.net/api/createStorage?code=ekher6NaUdHX9aOltc8z28zqugKfB8QbAR67HQUPJkgWAzFu32nKBw=="
$storageaccountdetails=@{
    "AccountName"="finalstorag15782"
  "AccountKind"="StorageV2"
  "AccountSKU"="Standard_LRS"
  "ResourceGroupName"="powershell-grp"
  "Location"="eastus"
  } | ConvertTo-Json

  Invoke-RestMethod -Uri $functionURi -Method Post

  $storageaccountdetails