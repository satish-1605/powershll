function get-resourceid {
    param (
        [String] $resourcename
    )
    $resource= Get-AzResource -name $resourcename 
    return $resource.id
}

$tags=@{

"Department"= "IT"
"Created by"= "Satish Gangwar"
"Tier"="1"
}
$resourcename= "app-vnet"
New-AzTag -Tag $tags -ResourceId (get-resourceid $resourcename)

$resourcename= "app-vnet"
$assignedTags= Get-AzTag  -ResourceId (get-resourceid $resourcename)
$keys=$assignedTags.Properties.TagsProperty.Keys
#$assignedkeys.Properties.TagsProperty.values

foreach ($key in $keys) {
    $assignedTags.Properties.TagsProperty.Item($key)
}





