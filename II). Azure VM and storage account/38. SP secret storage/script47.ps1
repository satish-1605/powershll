Disable-AzContextAutosave
Connect-AzAccount

$serviceprincipalname= "new-principal"
$serviceprincipal= New-AzADServicePrincipal -DisplayName $serviceprincipalname
$serviceprincipalsecret= $serviceprincipal.PasswordCredentials.SecretText


$ObjectID= "0c8395a7-7cf8-4027-8457-89bdbe632739"
Set-AzKeyVaultAccessPolicy -VaultName $keyvaultname -ResourceGroupName $ResourceGroupName `
-ObjectId $ObjectID -PermissionsToSecrets get,set

$keyvaultname= "app-keyvault1218275"
$secretvalue= ConvertTo-SecureString $serviceprincipalsecret -AsPlainText -Force

Set-AzKeyVaultSecret -VaultName $keyvaultname -name $serviceprincipalname -SecretValue $secretvalue