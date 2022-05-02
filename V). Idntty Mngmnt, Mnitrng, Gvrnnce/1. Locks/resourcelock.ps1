function get-resourcetype {
    param (
        [String] $resourcename
    )
    $resource= Get-AzResource -Name $resourcename
    return $resource.ResourceType
}

function get-azresourcegroupname {
    param (
        [String] $resourcename
    )
    $resource= Get-AzResource -Name $ResourceName
    return $resource.ResourceGroupName
}
Connect-AzAccount
$resourcename= "app-vnet"

$lock=New-AzResourceLock -LockName "LockA" -LockLevel ReadOnly -ResourceName $resourcename `
-ResourceType (get-resourcetype $resourcename) -ResourceGroupName (get-azresourcegroupname $resourcename) -Force

$lock=Get-AzResourceLock -LockName "LockA" -ResourceName $resourcename `
-ResourceType (get-resourcetype $resourcename) -ResourceGroupName (get-azresourcegroupname $resourcename)

if ($lock -ne $null) {

    Remove-AzResourceLock -LockName "LockA" -ResourceName $resourcename `
    -ResourceType (get-resourcetype $resourcename) `
    -ResourceGroupName (get-azresourcegroupname $resourcename)-Force
    'The lock is remove ' +$lock
}
else {
    'There is no lock attched with the resource'
}