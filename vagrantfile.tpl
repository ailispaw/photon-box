unless Vagrant.has_plugin?("vagrant-guests-photon")
  puts "--- WARNING ---"
  puts "You need vagrant-guests-photon plugin to use this box."
  puts "  $ vagrant plugin install vagrant-guests-photon"
  puts "Cf.) https://github.com/vmware/vagrant-guests-photon"
  exit
end

Vagrant.configure('2') do |config|
  # Forward the Docker port
  config.vm.network :forwarded_port, guest: 2375, host: 2375, auto_correct: true

  # Disable synced folder by default
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider :virtualbox do |vb|
    vb.check_guest_additions = false
  end
end
