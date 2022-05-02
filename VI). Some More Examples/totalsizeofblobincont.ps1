#total size of blob in a container

$accountname= "scalesetstorage16051995"
$resourcegrpname="staging-grp"
$containername="data"

$storageaccount= Get-AzStorageAccount -ResourceGroupName $resourcegrpname -Name $accountname

$blobs= Get-AzStorageBlob -Container $containername -Context $storageaccount.Context

$totalSize=0

foreach($blob in $blobs)
{
    $totalSize+=$blob.Length
    
}
"Total size of all the blobs in $containername is " + ($totalSize/1024/1024) + "MB"