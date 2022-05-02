$Tagname= "Created by"
$tagvalue= "Satish Gangwar"

$resources=Get-AzResource -TagName $Tagname -TagValue $tagvalue

$i=1
 "There are " + $resources.count + " resources are there with desired tag name and value"
foreach($resrce in $resources)
{
 'resource ' + $i + ' :'
'The name of  Resource is ' +$resrce.ResourceName
'The type of the resource is ' +$resrce.ResourceType

$i++

}
