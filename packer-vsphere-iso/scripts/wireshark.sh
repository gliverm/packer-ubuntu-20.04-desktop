#!/bin/bash -eux
# Commands tested but script not executed in a VM Build

# Set debian frontend to non interactive: man 7 debconf
export env DEBIAN_FRONTEND="noninteractive"

add-apt-repository -y ppa:wireshark-dev/stable
apt-get -y update
echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
apt-get -y install wireshark
usermod -aG wireshark $USER
chgrp wireshark /usr/bin/dumpcap
chmod 750 /usr/bin/dumpcap
setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap

# Install Tshark
apt-get -y install tshark
groupadd tshark
usermod -aG tshark $USER
chgrp tshark /usr/bin/dumpcap
chmod 750 /usr/bin/dumpcap
setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap
# Login to new group
# newgrp tshark
# Test Tshark works
# tshark -i wlan1 -c 1 -q