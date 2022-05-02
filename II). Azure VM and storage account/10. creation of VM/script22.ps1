#understanding of different publishers/offer/sku

$location ="North Europe"
$publishername= "canonical"


Get-AzVMImagePublisher -Location $location `
| Where-Object {$_.PublisherName -eq $publishername}


Get-AzVMImageOffer -Location $location -PublisherName $publishername
$offer= "UbuntuServer"

Get-AzVMImageSku -Location $location -PublisherName $publishername -Offer $offer 

$sku= "18.04-LTS"

Get-AzVMImage -Location $location -PublisherName $publishername -Offer $offer -Skus $sku 