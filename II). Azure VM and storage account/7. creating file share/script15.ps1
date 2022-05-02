$Accountname= "stoargeaccnt"
$ResourceGrpname="myRG"


$storageaccount= Get-AzStorageAccount -AccountName $Accountname -ResourceGroupName $ResourceGrpname

$fileshareconfig=@{

    Context= $storageaccount.Context
    Name='filesharedata'
}

#splatting - directly taking values from hash values
New-AzStorageShare @fileshareconfig

#creating directory inside file share
$directoryname=@{
    Context= $storageaccount.Context
    sharename='filesharedata'
    path='files'
}

New-AzStorageDirectory @directoryname


# Finally we will upload a file to the file share

$FileDetails=@{
    Context=$StorageAccount.Context
    ShareName = "data"
    Source="sample.txt"
    Path="/files/sample.txt"
}

Set-AzStorageFileContent @FileDetails