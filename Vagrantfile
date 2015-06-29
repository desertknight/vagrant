# -*- mode: ruby -*-
# vi: set ft=ruby :

# Config Github Settings
git_name = "Zlatko Hristov"
git_email = "zlatko.2create@gmail.com"

php_timezone = "Europe/Sofia"

mysql_password = "mysecretmysqlpassword"

Vagrant.configure(2) do |config|

  # Use official debain wheezy box
  config.vm.box = "debian/wheezy64"

  # I like this hostname, commented or remove if u wanna
  config.vm.hostname = "development"

  # Our installer script, please change settings
  # 1) MySQL root password
  # 2) Git config user.name
  # 3) Git config user.email
  config.vm.provision :shell, :path => "bootstrap.sh",
    :args => [mysql_password, php_timezone, git_name, git_email]

  # Forwared port, define here
  config.vm.network "forwarded_port", guest: 80, host: 80
  config.vm.network "forwarded_port", guest: 443, host: 443
  config.vm.network "forwarded_port", guest: 3306, host: 3306

  # Create a public network
  config.vm.network "public_network"

  # Share some web folder
  config.vm.synced_folder "e:/www", "/var/www", nfs: true, owner: "www-data", group: "www-data"

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
