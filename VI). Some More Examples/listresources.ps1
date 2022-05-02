#Listing all the rresources

#Connect-AzAccount

$Resourcegroup=Get-AzResourceGroup
$resources=@()
foreach ($RG in $Resourcegroup) {

    $resources+=get-azresource -ResourceGroupName $RG.ResourceGroupName
    
}
$resourceinformation=@()
foreach ($resource in $resources) {
    
        $resourceinfo=[PSCustomObject]@{
            Name = $resource.Name
            ResourceGroupName= $resource.ResourceGroupName
            Location= $resource.Location
        }
        $resourceinformation+=$resourceinfo
    }
    $resourceinformation | Export-Csv -Path "D:/Resources.csv"