Photon Vagrant Box for VirtualBox

```
$ git clone https://github.com/ailispaw/photon-box.git
$ cd photon-box
$ make
```

```
$ vagrant plugin install vagrant-guests-photon
$ vagrant box add -f photon-mini photon-mini.box
$ vagrant init -m photon-mini
$ vagrant up
```
