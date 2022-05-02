$Accountname= "stoargeaccnt"
$accounttype="StorageV2"
$AccountSKU= "Standard_LRS"
$ResourceGrpname="myRG"
$location= "east US"


#check for the existence of the storage account
if(Get-AzStorageAccount -AccountName $Accountname -ResourceGroupName $ResourceGrpname)
{
    'srorage accout already exists'
    #$storageaccount= Get-AzStorageAccount -AccountName $Accountname -ResourceGroupName $ResourceGrpname
}
else {
'creating a new storage account'
$storageaccount= New-AzStorageAccount -ResourceGroupName $ResourceGrpname -Name $Accountname `
-SkuName $AccountSKU -Location $location -Kind $accounttype
}
#$storageaccount


#existence of the container 
$container= "data"
if(Get-AzStorageContainer -Name $container -Context $storageaccount.Context -ErrorAction SilentlyContinue)
{
    'container already exists'
    #$con= Get-AzStorageContainer -Name $container -Context $storageaccount.Context
    
}
else{
    'otherwise conatiner will  be created'
    New-AzStorageContainer -Name $container -Context $storageaccount.Context -permission Blob
}
#$con

#upload a blob
$blobobject =@{
    Filelocation =".\sample.txt"
    objectname= ".\sample.txt"
}
if (Get-AzStorageBlob -Context $storageaccount.Context -Container $container -blob $blobobject['objectname']`
 -ErrorAction SilentlyContinue) {
    
    'blob already exists'
    #$blob= Get-AzStorageBlob -Context $storageaccount.Context -Container $container -blob $blobobject['objectname']
}
else {
    'create a blob'
    Set-AzStorageBlobContent -Context $storageaccount.Context -Container $container `
-file $blobobject['Filelocation'] -blob $blobobject['objectname']

}
#$blob
