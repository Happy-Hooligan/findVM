Set-ExecutionPolicy -ExecutionPolicy Bypass
#Connect-AzAccount

#Get VM Name 

$vmName = Read-Host -Prompt "Please enter the name of the Virtual Machine to find"

#Get all subscriptions to loop through
$subscriptions = Get-AzContext -ListAvailable
$AllVMs = foreach($subscription in $subscriptions) { 
    Select-AzContext $subscription.name  ; Get-AzVM 
}
$theVM = $AllVMs | where name -like "$vmName"
$subNumber = ($theVM.Id -split '/')[2]
$vmContext = Get-AzContext -ListAvailable | where subscription -Like "$subNumber"
Select-AzContext $vmContext.name
$vm = Get-AzVM -Name $vmName -Status
$vm | select name,LicenseType,Location,ResourceGroupName,powerstate

#Show Creation time. Can remove select filter and -diskname, and get a lot more info. -split "/" is taking that delimeter with the 
# managedby property and taking the value after the 8th instance. 

get-azdisk -ResourceGroupName $vm.ResourceGroupName -DiskName $vm.storageProfile.osDisk.name | Select-Object TimeCreated #, Name, @{N="VMname"; e = {($_.managedby -split "/")[8]} }

Write-Host "Local Admin Account"
Write-Host "======================="
Write-Host ""
$vm.OSProfile.AdminUsername
Write-Host ""
Write-Host ""
Write-Host "Operating System Information"
Write-Host "============================"
$vm.StorageProfile.ImageReference
Write-Host ""
Write-Host "VM Size"
Write-Host "============"
Write-Host "" 
$vm.HardwareProfile.VmSize
#OSDisk name and Size
Write-Host ""
Write-Host "OS Disk Info"
Write-Host "======================"
$vm.storageProfile.osDisk | select name, DiskSizeGB
#DataDisk Name, lun and size
Write-Host "Data Disks Info"
Write-Host "========================="
$vm.StorageProfile.datadisks | select name,lun,disksizeGB
#Get VM Tags
Write-Host ""
Write-Host "Virtual Machine Tags"
Write-Host "======================="
# $vm.Tags   This method had more spacing in the output. get-aztag looks much better

Get-AzTag -ResourceId $vm.id | Select-Object -ExpandProperty PropertiesTable

Write-Host ""
Write-Host VM Extensions
Write-Host "==================="
Get-AzVMExtension -VMName $vm.Name -ResourceGroupName $vm.ResourceGroupName | select name,publisher,extensiontype,provisioningstate

Write-Host ""
#Networking Info
Write-Host "Networking Info"
Write-Host "=================="

$vmNIC = Get-AzNetworkInterface -ResourceId $vm.NetworkProfile.NetworkInterfaces.id
$vmVNet = ($vmNIC.IpConfigurations.subnet.Id -split '/')[8]
$vmSubnet = ($vmNIC.IpConfigurations.subnet.Id -split '/')[10]
$nsg = ($vmNIC.NetworkSecurityGroup.Id -split '/')[8]


Get-AzNetworkInterface -ResourceId $vm.NetworkProfile.NetworkInterfaces.id | select name,primary
(Get-AzNetworkInterface -ResourceId $vm.NetworkProfile.NetworkInterfaces.id).IpConfigurations | select privateIPaddress,PrivateIpAllocationMethod,PublicIpAddress
Write-Host "DNS Settings on the NIC"
Write-Host "---------------------"
(Get-AzNetworkInterface -ResourceId $vm.NetworkProfile.NetworkInterfaces.id).DnsSettingsText
Write-Host "Network Security Group"
Write-Host "---------------------"
Get-AzNetworkSecurityGroup -Name $nsg | select name,type
Write-Host "-------VNET and Subnet----"
Write-Host Virtual Network is $vmVNet
Write-Host Virtual Subnet is $vmSubnet
Write-Host ""
Write-Host "DNS Settings at VNet level"
Write-Host "--------------------"
Get-AzVirtualNetwork -Name $vmVNet | select -ExpandProperty dhcpoptionstext  
###Left to do: Print VNet and show get-azvirtualnetwork command with saved variable. Same with subnet and show whether 
### DNS is on NIC or virtual network settings. 
### Virtual Network its DHCPoptions Get-AzVirtualNetwork -Name $virtualNetwork | select -ExpandProperty dhcpoptionstext

#(Get-AzNetworkInterface -ResourceId $vm.NetworkProfile.NetworkInterfaces.id).IpConfigurations.subnettext
#(Get-AzNetworkInterface -ResourceId $vm.NetworkProfile.NetworkInterfaces.id).IpConfigurations.privateipaddress

