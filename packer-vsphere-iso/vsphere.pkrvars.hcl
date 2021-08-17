##################################################################################
# VARIABLES
# variable assignment in order of ascending prescendence: 
#   variable defaults, environment variables, variable files, command-line flag
##################################################################################

# Credentials

# export PKR_VAR_vsphere_username=your_vsphere_username
# export PKR_VAR_vsphere_password=your_vsphere_password
# export PKR_VAR_ssh_username=vm_ssh_username
# export PKR_VAR_ssh_password=vm_ssh_password
vcenter_username                = "vcenter_username"
vcenter_password                = "vcenter_password"
ssh_username                    = "ubuntu"
ssh_password                    = "ubuntu"

# vSphere Objects

vcenter_insecure_connection     = true
vcenter_server                  = "10.253.100.145"
#vcenter_datacenter              = ""
vcenter_host                    = "10.253.68.134"
vcenter_datastore               = "VM_Datastore"
vcenter_network                 = "VM Network"
#vcenter_folder                  = ""

# ISO Objects
iso_path                        = "iso"