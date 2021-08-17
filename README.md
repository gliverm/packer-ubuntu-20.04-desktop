# packer-ubuntu-20.04-desktop

This repo was built as an experiment to learn how to build a Ubuntu Server/Desktop from an ISO on vCenter.  I learned a ton from: https://github.com/efops/packer-ubuntu20.04

The 3 main sections follow:

*  Notes to Self - Just some notes (right or wrong) made during the journey
*  Build the Desktop VM - Notes on how to actually do the build
*  User Setup After VM Build - Notes onthe user portion of the setup 

# Notes to Self

Why Packer? 
  * open-source
  * create identical machine images for multiple machines from a single source configuration - in code
  * Method to create VM template
  
Ubuntu 20.04 build notes
  * Subiquity installer only for servers
  * debian-isntaller(d-i) is EOL'd - do not use preseed
  * Install server and then add ubuntu-desktop as a package to install
  * Use autoinstall for unattended installation
   
Files/Folders
* Ubuntu server ISO must be uploaded to the vSphere datastore
* `*.pkr.hcl`
  * The `*.pkr.hcl` contains configuration settings for packer to build and provision the VM, connect to the vCenter server, etc.
  * Several organization methods for `*.pkr.hcl` file.  For re-usability it may be optimal to variablize most everything that may change and then store the values in one or more `.pkrvars.hcl` files.  In this example the file `vsphere.pkrvars.hcl` contains all the variables that are specific to the VCenter.  The file `vsphere-vm.pkrvars.hcl` contains all the variables specific to the VM being built.  This organization method allows for the main configuration file to stay untouched and swap variables to build different VMs.
* `user-data` and `meta-data`
  * Files `user-data` and `meta-data` are used for unattended installation of Ubuntu server
  * When a system is installed the autoinstall file for repeating the isntall is created at `/var/log/installer/autoinstall-user-data`.  This file from a manual VM build may helpful to create the `user-data` file.
  * Although the `meta-data` file is empty it must be present
  * Packer mounts the `user-data`  and `meta-data` files as CDROM's to the vSphere guest VM
  * Consider how a template script to create `user-data` files from Jinja2 templates to modify the identity values.   
* Script files
  * Used for provisioning after the VM is built.  Great for installing any packages or other settings that may be needed.

# Build the Desktop VM
This section outlines how to prepare packer for execution and building of a new VM.

1.  Modify VM Specific Data in `user-data`.  The VM password must be SHA512 salted.  Use the following docker command to create a password: 
`docker run --rm -ti alpine:latest mkpasswd -m sha512`

2. Modify VM variable information in `vsphere-vm.pkvars.hcl`. 

3. Run Packer to Create VM.  During the development of this flow the Ubuntu 20.04 server install has failed.  A bit of exploration has been done but a reason and fix has not been determined at this writing.  The build step may need to be repeated for a successful build. 

  * Initialize packer: `packer init .`
   * Build the VM: `packer build -var-file=vsphere.pkrvars.hcl --var-file=vsphere-vm.pkrvars.hcl .`

If executing from MacOS it may be necessary to flush the current known hosts SSH key from the `/Users/<username>/.ssh/known-hosts` file.  Use `ssh-keygen -R <hostname-or-ip>` to flush out the old ssh key.

# User Setup After VM Build
This section outlines settings a user can implement once the VM has been released for use.  These settings are optional per user preference.

## Set user to not require sudo for Docker (Optional)
Docker is setup to run as sudo.  Do the following to enable user to run without sudo.  

1.  ssh into the target Ubuntu machine
2.  Add your user to the `docker` group: `sudo usermod -aG docker $USER`
3.  Ether logout or run the following to activate changes: `newgrp docker`
4.  Test docker operation: `docker run hello-world`
   
## VNC Server Setup (Optional)
Screen sharing can be enabled after a user is logged into the Ubuntu 20.04 Gnome 3 desktop.  Since the desktop is built as a VM the user will initially have SSH access.  The intention of this section is to describe a solution that provides a Gnome 3 desktop remotely.  This section is optional as users may have different desktop preferences.

Credit for this section: https://www.cyberciti.biz/faq/install-and-configure-tigervnc-server-on-ubuntu-18-04/

1.  ssh into the target Ubuntu machine
2.  Install required packages: `sudo apt install tigervnc-standalone-server tigervnc-xorg-extension tigervnc-viewer`
3.  Setup VNC password: `vncpasswd`.  Make the password strong.  Do not need to enter a view-only password.  The password file is built in ~/.vnc/.
4.  Use nano editor to create the file `xstartup` in ~/.vnc/.  The file content should be as follows:

    ```
    #!/bin/sh
    # Start Gnome 3 Desktop 
    [ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
    [ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
    vncconfig -iconic &
    dbus-launch --exit-with-session gnome-session &
    ```

5. Start vncserver: `vncserver --localhost no'
6. Use a VNC viewer on a remote machine to connect to the VNC server.  From experience on MacOS a suggestion is to use VNC Connect by RealVNC client.  This viewer allows cut and past between the VNC session and the viewing computer.

Additional VNC Server Info:

*  List vncserver sessions: `vncserver -list`
*  To stop vncserver: `vncserver -kill :1`
*  The client may exit the ssh session and the vncserver connection will stay in place.
*  The client may exit the VNC session may be exited and reconnected to the same VNC session.
*  The vncserver is not configured to be restarted when the VM restarts.  A user will need to ssh into the VM and restart the vncserver or add vncserver as a service to be restarted automatically on VM reboot/power off/on scenarios.
  
