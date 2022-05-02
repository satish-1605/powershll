
function  get-sourcerg {
    param (
        [String] $resourcename 
    )
    $resource= Get-AzResource -Name $resourcename 
    return $resource.ResourceGroupName
}

function  get-rgId {
    param (
        [String] $ResourceGroupName
    )
    $resourcegrp= Get-AzResourceGroup -Name $ResourceGroupName
    return $resourcegrp.ResourceId
}
function  get-resourceid {
    param (
        [String] $resourcename
    )
    $resource= Get-AzResource -Name $resourcename
    return $resource.ResourceId
}

$resourcename = "webapp987987"
$destRG= "powershell-grp"
$sorceRg= (get-sourcerg $resourcename)
$sorceRgId= (get-rgId $sorceRg)
$destRGId= (get-rgId $destRG)
$resourceId= (get-resourceid $resourcename)

Invoke-AzResourceAction -Action validateMoveResources -ResourceId $sorceRgId `
-Parameters @{resources=@($resourceId);destresGroup=@($destRGId)} -Force 

Move-AzResource -DestinationResourceGroupName $destRG -ResourceId $resourceId 

