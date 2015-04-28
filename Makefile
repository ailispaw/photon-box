photon-mini.box: photon-mini.json photon.iso vagrant_plugin_guest_photon.rb \
	scripts/install_packages.sh scripts/install_vboxguest.sh \
	scripts/provisioning.sh scripts/cleanup.sh \
	units/systemd-machine-id-setup.service units/vboxguest.service \
	units/docker.service units/docker-tcp.socket units/docker-tcp.socket
	packer build photon-mini.json

photon.iso:
	curl -L https://dl.bintray.com/vmware/photon/iso/1.0TP1/x86_64/photon-1.0TP1.iso \
		-o photon.iso

test:
	vagrant destroy -f
	vagrant box add -f photon-mini photon-mini.box
	vagrant up

clean:
	vagrant destroy -f
	$(RM) -r packer_cache
	$(RM) photon-mini.box
	$(RM) photon.iso

.PHONY: test clean
