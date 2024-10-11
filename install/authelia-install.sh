#!/usr/bin/env bash

# Copyright (c) 2021-2024 tteck
# Author: tteck
# Co-Author:: Mateusz Krawczuk
# License: MIT
# https://github.com/tteck/Proxmox/raw/main/LICENSE

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y curl
$STD apt-get install -y sudo
$STD apt-get install -y mc
$STD apt-get install -y gpg
$STD apt-get install -y ca-certificates

msg_ok "Installed Dependencies"

msg_info "Installing lldap"
source /etc/os-release
os=$ID
if [ "$os" == "ubuntu" ]; then
  DISTRO="xUbuntu"
else
  DISTRO="${os^}"
fi
curl -fsSL https://apt.authelia.com/organization/signing.asc -o /usr/share/keyrings/authelia.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/authelia.asc] https://apt.authelia.com/stable/debian/debian all main" | \
  sudo tee /etc/apt/sources.list.d/authelia.list > /dev/null
$STD apt update
$STD apt install -y authelia
systemctl enable -q --now authelia
msg_ok "Installed authelia"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
