# Photon Vagrant Box for VirtualBox

- Photon Container OS (Minimal) Installation
- Docker v1.6.1
- Install sudo
- Add docker group and add vagrant to the docker group
- Generate unique /etc/machine-id on the first boot
- Support Docker provisioner
- Support NFS synced folder
- Support VirtualBox Shared Folder
- 117MB

## How to Build a Box

```
$ git clone https://github.com/ailispaw/photon-box.git
$ cd photon-box
$ make
```

## Vagrant Up

```
$ vagrant plugin install vagrant-guests-photon
$ vagrant box add -f photon-mini photon-mini.box
$ vagrant init -m photon-mini
$ vagrant up
```

## Sample Vagrantfile

```ruby
Vagrant.configure(2) do |config|
  config.vm.define "photon"

  config.vm.box = "photon-mini"

  config.vm.hostname = "photon.example.com"

  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.synced_folder ".", "/vagrant"
# Or
# config.vm.synced_folder ".", "/vagrant", type: "nfs", mount_options: ["nolock", "vers=3", "udp"]

  config.vm.provision :docker do |d|
    d.pull_images "busybox"
    d.run "simple-echo",
      image: "busybox",
      args: "-p 8080:8080 --restart=always",
      cmd: "nc -p 8080 -l -l -e echo hello world!"
  end

  config.vm.network :forwarded_port, guest: 8080, host: 8080
end
```
