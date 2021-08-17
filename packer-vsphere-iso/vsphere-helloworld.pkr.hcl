# Maintainer: 
##################################################################################
# PACKER
##################################################################################

packer {
  required_version = ">= 1.7.3"
  required_plugins {
    vsphere = {
      version = ">= 0.0.1"
      source = "github.com/hashicorp/vsphere"
    }
  }
}

##################################################################################
# VARIABLES
##################################################################################

#--- Credentials

variable "vcenter_username" {
  type    = string
  description = "The username for authenticating to vCenter."
  default = ""
  sensitive = true
}

variable "vcenter_password" {
  type    = string
  description = "The plaintext password for authenticating to vCenter."
  default = ""
  sensitive = true
}

variable "ssh_username" {
  type    = string
  description = "The username to use to authenticate over SSH."
  default = ""
  sensitive = true
}

variable "ssh_password" {
  type    = string
  description = "The plaintext password to use to authenticate over SSH."
  default = ""
  sensitive = true
}

#--- vSphere Objects

variable "vcenter_insecure_connection" {
  type    = bool
  description = "If true, does not validate the vCenter server's TLS certificate."
  default = true
}

variable "vcenter_server" {
  type    = string
  description = "The fully qualified domain name or IP address of the vCenter Server instance."
  default = ""
}

# variable "vcenter_datacenter" {
#   type    = string
#   description = "Required if there is more than one datacenter in vCenter."
#   default = ""
# }

variable "vcenter_host" {
  type = string
  description = "The ESXi host where target VM is created."
  default = ""
}

variable "vcenter_datastore" {
  type    = string
  description = "Required for clusters, or if the target host has multiple datastores."
  default = ""
}

variable "vcenter_network" {
  type    = string
  description = "The network segment or port group name to which the primary virtual network adapter will be connected."
  default = ""
}

# variable "vcenter_folder" {
#   type    = string
#   description = "The VM folder in which the VM template will be created."
#   default = ""
# }

#--- ISO Objects

variable "iso_path" {
  type    = string
  description = "The path on the source vSphere datastore for ISO images."
  default = ""
  }

variable "iso_file"{
  type = string
  description = "The file name of the guest operating system ISO image installation media."
  default = ""
}

variable "iso_checksum" {
  type    = string
  description = "The SHA-512 checkcum of the ISO image."
  default = ""
}

#--- HTTP Endpoint

variable "http_directory" {
  type    = string
  description = "Directory of config files(user-data, meta-data)."
  default = ""
}

#--- Virtual Machine Settings

# variable "vm_guest_os_family" {
#   type    = string
#   description = "The guest operating system family."
#   default = ""
# }

# variable "vm_guest_os_vendor" {
#   type    = string
#   description = "The guest operating system vendor."
#   default = ""
# }

# variable "vm_guest_os_member" {
#   type    = string
#   description = "The guest operating system member."
#   default = ""
# }

# variable "vm_guest_os_version" {
#   type    = string
#   description = "The guest operating system version."
#   default = ""
# }

variable "vm_name_prefix" {
  type    = string
  description = "The prefix of the VM name.  Intended to identify VM OS."
  default = ""  
}

variable "vm_name_suffix" {
  type    = string
  description = "The suffix of the VM name.  Intended to be unique to prefix."
  default = ""  
}

variable "vm_guest_os_type" {
  type    = string
  description = "The guest operating system type, also know as guestid."
  default = ""
}

variable "vm_version" {
  type = number
  description = "The VM virtual hardware version."
}

# variable "vm_firmware" {
#   type    = string
#   description = "The virtual machine firmware. (e.g. 'bios' or 'efi')"
#   default = ""
# }

variable "vm_cdrom_type" {
  type    = string
  description = "The virtual machine CD-ROM type."
  default = ""
}

variable "vm_cpus" {
  type = number
  description = "The number of virtual CPUs."
}

# variable "vm_cores_per_socket" {
#   type = number
#   description = "The number of virtual CPUs cores per socket."
# }

variable "vm_mem_size" {
  type = number
  description = "The size for the virtual memory in MB."
}

variable "vm_video_ram" {
  type = number
  description = "The size for the virtual video card memory in KB."
}

variable "vm_disk_size" {
  type = number
  description = "The size for the virtual disk in MB."
}

variable "vm_disk_controller_type" {
  type = list(string)
  description = "The virtual disk controller types in sequence."
}

variable "vm_network_card" {
  type = string
  description = "The virtual network card type."
  default = ""
}

variable "vm_boot_wait" {
  type = string
  description = "The time to wait before boot. "
  default = ""
}

variable "shell_scripts" {
  type = list(string)
  description = "A list of scripts."
  default = []
}

##################################################################################
# LOCALS
##################################################################################

locals { 
  buildtime = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  }

##################################################################################
# SOURCE
# source blocks are analogous to the "builders" in json templates. They are used
# in build blocks. A build block runs provisioners and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
##################################################################################

# Source documentation: https://www.packer.io/docs/builders/vsphere/vsphere-iso
source "vsphere-iso" "ubuntu-svr" {
  
  #--- Connection Configuration
  vcenter_server                = var.vcenter_server
  username                      = var.vcenter_username
  password                      = var.vcenter_password
  insecure_connection           = var.vcenter_insecure_connection
  #datacenter

  #--- Location Configuration
  vm_name                       = "${var.vm_name_prefix}-${var.vm_name_suffix}"
  #folder
  #cluster
  host                          = var.vcenter_host
  #resourcepool
  #cluster
  datastore                     = var.vcenter_datastore

  #--- VM Configuration
  vm_version                    = var.vm_version
  guest_os_type                 = var.vm_guest_os_type
  notes                         = "Built by HashiCorp Packer on ${local.buildtime}."
  CPUs                          = var.vm_cpus
  RAM                           = var.vm_mem_size
  video_ram                     = var.vm_video_ram
  disk_controller_type          = var.vm_disk_controller_type
  storage {
    disk_size                   = var.vm_disk_size
    disk_controller_index       = 0
    disk_thin_provisioned       = true
  }
  network_adapters {
    network                     = var.vcenter_network
    network_card                = var.vm_network_card
  }
  tools_sync_time               = true
  tools_upgrade_policy          = true
  remove_cdrom                  = true
  convert_to_template           = false
  
  #--- ISO & Boot Configuration
  cdrom_type    = var.vm_cdrom_type
  iso_paths    = ["[${ var.vcenter_datastore }] /${ var.iso_path }/${ var.iso_file }"]
  #iso_paths     = ["[VM_Datastore] iso/ubuntu-20.04.2-live-server-amd64.iso"]
  iso_checksum  = "sha256:var.iso_checksum"
  #iso_checksum  = "sha256:d1f2bf834bbe9bb43faf16f9be992a6f3935e65be0edece1dee2aa6eb1767423"
  cd_files      = ["./${var.http_directory}/*"]
  #cd_files      = ["./http/*"]
  cd_label      = "cidata"
  boot_wait     = var.vm_boot_wait
  boot_command = [
    "<esc><esc><esc>",
    "<enter><wait>",
    "/casper/vmlinuz ",
    "initrd=/casper/initrd ",
    "autoinstall ",
    "<enter>"
  ]

  #--- SSH Configuration
  ssh_username                 = var.ssh_password
  ssh_password                 = var.ssh_username
  ssh_timeout                  = "30m"
  ssh_handshake_attempts       = "100000"

  #--- Shutdown Configuration
  shutdown_command             = "echo '${var.ssh_password}'|sudo -S shutdown -P now"
  shutdown_timeout             = "15m"
  #disable_shutdown            = false
}

##################################################################################
# BUILD
##################################################################################

build {
  sources = ["sources.vsphere-iso.ubuntu-svr"]
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"
    ]
  }
  provisioner "shell" {
    execute_command = "echo '${var.ssh_password}' | {{.Vars}} sudo -S -E bash '{{.Path}}'"
    environment_vars = [
      "BUILD_USERNAME=${var.ssh_username}",
    ]
    scripts = ["./scripts/setup_ubuntu2004_dev.sh"]
    #expect_disconnect = true
  }
  provisioner "shell" {
    scripts = ["./scripts/usersettings_ubuntu2004_dev.sh"]
    #expect_disconnect = true
  }
}