$ResourceGrpname ="myRG"
$VmName="appvm"


$Status= (Get-AzVM -ResourceGroupName $ResourceGrpname -Name $VmName -Status).Statuses

#status of ProvisioningState(index -0) and PowerState(index 1) is showing
if($Status[1].Code -eq "PowerState/running")
{
    'shut down the Vm'
    Stop-AzVM -ResourceGroupName $ResourceGrpname -name $VmName -force
}
else {
   'Vm is not in running state'
}