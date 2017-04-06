# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/xenial64"

  # config.vm.network "forwarded_port", guest: 80, host: 8000
  config.vm.network "private_network", type: "dhcp"

  config.ssh.forward_agent = true
  config.vm.synced_folder ".", "/vagrant", disabled: false

  # Provider-specific configuration so you can fine-tune various
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "4096"
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "fix-no-tty", type: "shell" do |s|
    s.privileged = false
    s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end

  config.vm.provision "shell", path: "provision.updates.sh"
  config.vm.provision "shell", path: "provision.zoom.sh"
  config.vm.provision "shell", path: "provision.zoom.nginx.sh"
  config.vm.provision "shell", path: "provision.nginx.ssl.sh"
  # config.vm.provision "shell", path: "provision.zoom.apache.sh"
  config.vm.provision "shell", inline: "sudo reboot"
end
