# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.define 'rukkit-vagrant' do |c|
    c.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024"]
    end
    c.vm.box = "ffuenf/debian-7.6.0-amd64"
    c.vm.box_check_update = true
    c.vm.network "private_network", ip: "192.168.33.10"
    # c.vm.network "forwarded_port", guest: 80, host: 8080
    c.vm.network "forwarded_port", guest: 25565, host: 25565

    # sync rukkit source
    c.vm.synced_folder './', '/home/vagrant/rukkit', owner: 'vagrant', group: 'vagrant'

    # c.ssh.username = 'root'
    c.ssh.private_key_path = '~/.vagrant.d/insecure_private_key'

    # Make sure to use root user
    c.vm.provision :shell, inline: <<-EOC
    echo 'root:vagrant' | /usr/sbin/chpasswd
    EOC

    # c.vm.provision :shell, inline: <<-EOC
    # sudo mkdir /root/.ssh
    # sudo cp /home/vagrant/.ssh/authorized_keys /root/.ssh/
    # EOC
  end

end

