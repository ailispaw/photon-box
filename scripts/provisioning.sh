#!/bin/sh

HOME_DIR="/home/vagrant"

# Set up a vagrant user and add the insecure key for Vagrant to login
groupadd docker
useradd -g 999 -m vagrant -G docker

# Configure a sudoers for the vagrant user
echo "vagrant ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vagrant

# Set up insecure Vagrant key
mkdir -p ${HOME_DIR}/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > ${HOME_DIR}/.ssh/authorized_keys
chown -R vagrant:users ${HOME_DIR}/.ssh
chmod 700 ${HOME_DIR}/.ssh
chmod 600 ${HOME_DIR}/.ssh/authorized_keys

# Disable Root Login
sed -i "s/^PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config

# Disable SSH Password Authentication
if ! grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config; then
  echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
fi

# Disable SSH Use DNS
if ! grep -q "^UseDNS no" /etc/ssh/sshd_config; then
  echo "UseDNS no" >> /etc/ssh/sshd_config
fi

# Enable Docker to start at runtime
systemctl enable docker.socket
systemctl enable docker-tcp.socket
systemctl enable docker

ln -s /bin/docker /usr/bin/docker

# Enable VBoxGuest to start at runtime
systemctl enable vboxguest

# Generate /etc/machine-id on the next boot
systemctl enable systemd-machine-id-setup
rm -f /etc/machine-id
