#!/bin/bash

#
# Import Parent Shell
#
source /vagrant/shell/parent-shell.sh

#
# Variables
#
dns=""

TEMP=`getopt -o ab:c:: --long dns: -- "$@"`
eval set -- "$TEMP"

while true ; do
  case "$1" in
    --dns ) dns=$2;shift 2;;
    --)shift;break;;
  esac
done

#
# Functions
#

install_prerequisites() {
  info "Install prerequisites"
  dnf install epel-release -y
  dnf install git gcc gcc-c++ ansible nodejs gettext device-mapper-persistent-data lvm2 bzip2 python3-pip -y
}

install_docker() {
  info "Install Containerd.io"
  dnf install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm -y

  info "Install Dcoker"
  dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo -y
  dnf install docker-ce -y

  systemctl start docker
  systemctl enable docker

  usermod -aG docker $USER
}

install_docker_compose() {
  info "Install Docker Compose"
  pip3 install docker-compose
  alternatives --set python /usr/bin/python3
}

clone_awx_repo() {
  info "Clone AWX repo"
  git clone https://github.com/ansible/awx.git
}

edit_awx_inventory() {
  info "Edit AWX inventory"
  sed -i "s/secret_key=.*/secret_key=$(openssl rand -base64 30)/g" awx/installer/inventory
  sed -i "s/#awx_alternate_dns_servers=.*/awx_alternate_dns_servers=$dns/g" awx/installer/inventory
}

install_awx() {
  info "Install AWX"
  mkdir /var/lib/pgdocker
  ansible-playbook -i awx/installer/inventory awx/installer/install.yml
}

main() {
  install_prerequisites
  install_docker
  install_docker_compose
  clone_awx_repo
  edit_awx_inventory
  install_awx
}

main
