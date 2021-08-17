#!/bin/bash -eux

# This script should is an example of setting user settings.  This should probably be ultimately done at user discretion. 

# Disable Power Saving to a blank screen
gsettings set org.gnome.desktop.session idle-delay 0
