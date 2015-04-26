unless Vagrant.has_plugin?("vagrant-guests-photon")
  puts "--- WARNING ---"
  puts "You need vagrant-guests-photon plugin to use this box."
  puts "  $ vagrant plugin install vagrant-guests-photon"
  puts "Cf.) https://github.com/vmware/vagrant-guests-photon"
  exit
end

require 'tempfile'
require 'ipaddr'

# Borrowed from http://stackoverflow.com/questions/1825928/netmask-to-cidr-in-ruby
IPAddr.class_eval do
  def to_cidr
    self.to_i.to_s(2).count("1")
  end
end

STATIC_NETWORK = <<EOF
[Match]
Name=%s

[Network]
Address=%s
EOF

DHCP_NETWORK = <<EOF
[Match]
Name=%s

[Network]
DHCP=yes
EOF

require Vagrant.user_data_path.join("gems/gems/vagrant-guests-photon-1.0.0/lib/vagrant-guests-photon/cap/configure_networks.rb")
module VagrantPlugins
  module GuestPhoton
    module Cap
      class ConfigureNetworks
        include Vagrant::Util

        def self.configure_networks(machine, networks)
          machine.communicate.tap do |comm|
            comm.sudo("rm -f /etc/systemd/network/50-vagrant-*.network")

            networks.each do |network|
              iface = "eth#{network[:interface]}"
              unit_name = "50-vagrant-%s.network" % [iface]

              if network[:type] == :static
                cidr = IPAddr.new(network[:netmask]).to_cidr
                address = "%s/%s" % [network[:ip], cidr]
                unit_file = STATIC_NETWORK % [iface, address]
              elsif network[:type] == :dhcp
                unit_file = DHCP_NETWORK % [iface]
              end

              temp = Tempfile.new("vagrant")
              temp.binmode
              temp.write(unit_file)
              temp.close

              comm.upload(temp.path, "/tmp/#{unit_name}")
              comm.sudo("mv /tmp/#{unit_name} /etc/systemd/network/")
              comm.sudo("chown root:root /etc/systemd/network/#{unit_name}")
              comm.sudo("chmod +r /etc/systemd/network/#{unit_name}")
            end

            comm.sudo("systemctl restart systemd-networkd.service")
          end
        end
      end
    end
  end
end
