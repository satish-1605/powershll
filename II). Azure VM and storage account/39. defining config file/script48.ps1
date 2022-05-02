
param (
    [Parameter(Mandatory=$true)]
    [string]$Environment
)

$object= Get-Content -Raw -Path "C:\config.json" | ConvertFrom-Json 

$virtualnetwork=$null
$virtualnetworkaddspace=$null
$subnetnames=@()
$subnetaddspace=@()

switch ($Environment) {
    
    "Development"{
$virtualnetwork=$object.Development.virtualnetwork.Name
$virtualnetworkaddspace=$object.Development.virtualnetwork.Addressspace
$subnetnames+=$object.Development.Subnet.name
$subnetaddspace+=$object.Development.Subnet.Addressspace

    }
    "Staging"{
        $virtualnetwork=$object.Staging.virtualnetwork.Name
        $virtualnetworkaddspace=$object.Staging.virtualnetwork.Addressspace
        $subnetnames+=$object.Staging.Subnet.name
        $subnetaddspace+=$object.Staging.Subnet.Addressspace
    }
}
$subnet=@()
$subnetnames.count
for ($i = 1; $i -le 2; $i++) {
    $subnet+=New-AzVirtualNetworkSubnetConfig -Name $subnetnames[$i-1] -AddressPrefix $subnetaddspace[$i-1] `
}
$resourcegroupname="powershell-grp"
$Location="North Europe"

New-AzVirtualNetwork -Name $virtualnetwork -ResourceGroupName $resourcegroupname -Location $Location -AddressPrefix `
$virtualnetworkaddspace -Subnet $subnet
                                                   