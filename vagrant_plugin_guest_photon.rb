unless Vagrant.has_plugin?("vagrant-guests-photon")
  puts "--- WARNING ---"
  puts "You need vagrant-guests-photon plugin to use this box."
  puts "  $ vagrant plugin install vagrant-guests-photon"
  puts "Cf.) https://github.com/vmware/vagrant-guests-photon"
  exit
end

require Vagrant.user_data_path.join("gems/gems/vagrant-guests-photon-1.0.0/lib/vagrant-guests-photon/cap/configure_networks.rb")
module VagrantPlugins
  module GuestPhoton
    module Cap
      class ConfigureNetworks
        include Vagrant::Util

        def self.configure_networks(machine, networks)
          machine.communicate.tap do |comm|
            networks.each do |network|
              iface = "eth#{network[:interface]}"

              if network[:type] == :static
                comm.sudo("ifconfig #{iface} #{network[:ip]} netmask #{network[:netmask]}")
              end

              comm.sudo("ip link set #{iface} down")
              comm.sudo("ip link set #{iface} up")
            end
          end
        end
      end
    end
  end
end
