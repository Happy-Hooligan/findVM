# Find a Virtual Machine in your Azure Tenant

This script assumes a few things:
1) You have the Azure Powershell module installed on your machine.
2) You are already authenticated to your Azure tenant
These steps can be avoided by using the Azure Cloud Shell. You would need to select Powershell instead of bash--naturally.

Also, this script will cycle through all your subscriptions to look for the machine. If you have a very large environment 400+ machines, this could take a few minutes to run. 

When running the script (cough cough as admin), all you need to do is type the name of the virtual machine. This will not work as a "best effort." If it doesn't match a machine name, it will not work. Spelling is important.
