#################################################################################
# VARIABLES
##################################################################################

# HTTP Settings

http_directory = "http"

# Virtual Machine Settings

#vm_guest_os_family          = "linux"
#vm_guest_os_vendor          = "ubuntu"
#vm_guest_os_member          = "server"
#vm_guest_os_version         = "20-04-lts"
vm_name_prefix              = "ubuntu"
vm_name_suffix              = "desktop01"
vm_guest_os_type            = "ubuntu64Guest"
vm_version                  = 14
#vm_firmware                 = "bios"
vm_cdrom_type               = "sata"
vm_cpus                     = 2
#vm_cores_per_socket        = 1
vm_mem_size                 = 8192
vm_video_ram                = 64000
vm_disk_size                = 50000
vm_disk_controller_type     = ["pvscsi"]
vm_network_card             = "vmxnet3"
vm_boot_wait                = "2s"

# ISO Objects

iso_file                    = "ubuntu-20.04.2-live-server-amd64.iso"
iso_checksum                = "d1f2bf834bbe9bb43faf16f9be992a6f3935e65be0edece1dee2aa6eb1767423"

# Scripts

shell_scripts               = ["./scripts/setup_ubuntu2004_dev"]