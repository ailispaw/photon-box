Vagrant.configure(2) do |config|
  config.vm.define "photon-test"

  config.vm.box = "photon-mini"

  config.vm.hostname = "photon-test.example.com"

  config.vm.provision :docker do |d|
    d.pull_images "busybox"
    d.run "simple-echo",
      image: "busybox",
      args: "-p 8080:8080 --restart=always",
      cmd: "nc -p 8080 -l -l -e echo hello world!"
  end

  config.vm.network :forwarded_port, guest: 8080, host: 8080
end
