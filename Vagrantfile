Vagrant.configure('2') do |config|
  config.vm.define 'gis' do |config|
    config.vm.hostname = 'gis-vm'
    config.vm.box = 'ubuntu-1204-amd64'
    config.vm.box_url = 'http://vagrant.sensuapp.org/ubuntu-1204-amd64.box'
    # Disable automatic box update checking. If you disable this, then
    # boxes will only be checked for updates when the user runs
    # `vagrant box outdated`. This is not recommended.
    config.vm.box_check_update = false

    config.vm.provider "virtualbox" do |vb|
      # Don't boot with headless mode
      vb.gui = ENV['ENABLE_GUI'] == 'true'
      # Use VBoxManage to customize the VM. For example to change memory:
      vb.customize ["modifyvm", :id, "--memory", '1024']
      vb.customize ["modifyvm", :id, "--name", 'GIS Node']
    end

    # Create a forwarded port mapping which allows access to a specific port
    # within the machine from a port on the host machine. In the example below,
    # accessing "localhost:8080" will access port 80 on the guest machine.
    config.vm.network "forwarded_port", guest: 80, host: 8080

    # Create a private network, which allows host-only access to the machine
    # using a specific IP.
    config.vm.network "private_network", ip: "192.168.33.10"

    config.vm.provision :shell, :inline => <<CMD
if [[ -x /opt/chef/bin/chef-client ]]
then
  echo "Chef bootstrapped."
else
  rm -rf /opt/ruby
  apt-get install curl -y
  curl -L http://opscode.com/chef/install.sh | bash
fi
CMD

    config.vm.provision "chef_solo" do |chef|
      chef.cookbooks_path = %w(cookbooks)
      chef.roles_path = 'roles'
      #chef.data_bags_path = 'data_bags'
      #chef.provisioning_path = '/var/chef-cache'
      chef.add_role 'fgis_server'
      chef.json = {:fgis => {:app_server_addresses => []}}
    end
  end
end
