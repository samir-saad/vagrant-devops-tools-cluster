#!/bin/bash

#
# Import Parent Shell
#
source /vagrant/shell/parent-shell.sh

#
# Variables
# cockpit cockpit-networkmanager cockpit-dashboard cockpit-storaged cockpit-packagekit cockpit-docker cockpit-kubernetes cockpit-machines cockpit-selinux cockpit-kdump
packages="cockpit cockpit-networkmanager cockpit-dashboard cockpit-storaged cockpit-packagekit"

#
# Functions
#

main() {
  info "Install Cockpit packages: $packages"
  bulk_install $packages

  systemctl enable --now cockpit.socket
  systemctl start cockpit.socket

  #firewall-cmd --add-service=cockpit --permanent
  #firewall-cmd --reload
}

main
