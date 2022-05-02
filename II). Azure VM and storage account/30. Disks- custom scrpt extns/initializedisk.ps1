$disk= Get-Disk | Where-Object PartitionStyle -eq 'RAW'

$InitializedDisk=Initialize-Disk -Number $disk.Number -PartitionStyle MBR -PassThru 

$Partition= New-Partition -DiskNumber $disk.Number -UseMaximumSize -DriveLetter S 

Format-Volume -Partition $Partition -FileSystem NTFS -FileSystemLabel "Data" -Force -Confirm:$false