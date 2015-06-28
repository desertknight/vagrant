# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  # Use official debain wheezy box
  config.vm.box = "debian/wheezy64"

  # Our installer script
  config.vm.provision :shell, :path => "bootstrap.sh"

  # Forwared port, define here
  # config.vm.network "forwarded_port", guest: 80, host: 80

  # Create a public network
  config.vm.network "public_network"

  # Share some web folder
  # config.vm.synced_folder "e:/www", "/var/www", nfs: true, owner: "www-data", group: "www-data"

  # Enable with your values
  config.vm.provider "virtualbox" do |v, override|
    v.customize [ "modifyvm", :id, "--cpus", "2" ]
    v.customize [ "modifyvm", :id, "--memory", "2048" ]
  end

  config.vm.provider "vmware_fusion" do |v, override|
    v.vmx["numvcpus"] = "2"
    v.vmx["memsize"] = "2048"
  end
end
