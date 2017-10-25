# Native Open edX Ubuntu 16.04 64 bit Installation
# McDaniel
# October 2017
#
# To stand up a pristine single-server instance of Open edX Ginkgo.1
# this is a modification of the generic instructions from:
#   Native Open edX Ubuntu 16.04 64 bit Installation
#   https://openedx.atlassian.net/wiki/spaces/OpenOPS/pages/146440579/Native+Open+edX+Ubuntu+16.04+64+bit+Installation
#
# This script takes around 2 hours to complete. It is intended to be run unattended, on a background thread using
# nohup.


cd ~

# 1. Set the OPENEDX_RELEASE variable:
export OPENEDX_RELEASE=open-release/ginkgo.1

# 2. Bootstrap the Ansible installation:
wget https://raw.githubusercontent.com/edx/configuration/$OPENEDX_RELEASE/util/install/ansible-bootstrap.sh -O - | sudo bash

# 3. (Optional) If this is a new installation, randomize the passwords:
wget https://raw.githubusercontent.com/edx/configuration/$OPENEDX_RELEASE/util/install/generate-passwords.sh -O - | bash

# 4. Install Open edX:
wget https://raw.githubusercontent.com/edx/configuration/$OPENEDX_RELEASE/util/install/sandbox.sh -O - | bash > install.out
