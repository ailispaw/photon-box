Vagrant.configure(2) do |config|
  config.vm.define "photon-test"

  config.vm.box = "photon-mini"

  config.vm.hostname = "photon-test.example.com"

  config.vm.network :private_network, ip: "192.168.33.10"
#  config.vm.network :private_network, type: "dhcp"
#  config.vm.network :public_network, bridge: "en0: Wi-Fi (AirPort)"
#  config.vm.network :public_network, bridge: "en0: Wi-Fi (AirPort)", ip: "192.168.1.201"

  config.vm.synced_folder ".", "/vagrant"
#  config.vm.synced_folder ".", "/vagrant", type: "nfs", mount_options: ["nolock", "vers=3", "udp"]

  config.vm.provision :docker do |d|
    d.pull_images "busybox"
    d.run "simple-echo",
      image: "busybox",
      args: "-p 8080:8080 --restart=always",
      cmd: "nc -p 8080 -l -l -e echo hello world!"
  end

  config.vm.network :forwarded_port, guest: 8080, host: 8080
end
