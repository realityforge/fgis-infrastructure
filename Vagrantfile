$current_address=9
$current_port_forward_address=8079

def next_ip
  $current_address += 1
end

def ssh_port
  2212 + $current_address
end

def next_forward_port
  $current_port_forward_address += 1
end

def local_cache(basebox_name)
  cache_dir = Vagrant::Environment.new.home_path.join('cache', 'apt', basebox_name)
  partial_dir = cache_dir.join('partial')
  FileUtils.mkdir_p partial_dir unless partial_dir.exist?
  cache_dir
end

def network_prefix
  "192.168.77"
end

require 'socket'

local_ip_addresses =
  Socket.
    ip_address_list.
    select{|a| a.ipv4? && !a.ipv4_loopback?}.
    collect{|a| a.ip_address}.
    select{|a| !(a =~ /^#{network_prefix.gsub('.',"\\.")}\..*/)}.
    sort.uniq

boxen = {
  :gis => {
    :description => "GIS Node",
    :recipes => [],
    :roles => ['fgis_server'],
    :ipaddress => "#{network_prefix}.#{next_ip}",
    :forwards => {22 => ssh_port, 5432 => 5432, 80 => 8080, 8085 => 8085},
    :json => {:fgis => {:app_server_addresses => local_ip_addresses}},
  }
}

Vagrant::Config.run do |global_config|
  boxen.each_pair do |key, options|
    global_config.vm.define key.to_s do |config|
      config.vm.boot_mode = ENV["ENABLE_GUI"] == 'true' ? :gui : :headless
      config.vm.host_name = "#{key.to_s.gsub('_', '-')}-vm"
      config.vm.network :hostonly, options[:ipaddress]

      config.vm.box = options[:box_key] || "ubuntu-1204-amd64"
      config.vm.box_url = options[:box_url] || "http://vagrant.sensuapp.org/ubuntu-1204-amd64.box"

      customizations = []
      customizations += ["--name", "#{key}: #{options[:description]}"]
      customizations += ["--memory", options[:memory].to_s] if options[:memory]
      customizations += ["--cpus", options[:cpus].to_s] if options[:cpus]

      config.vm.customize(["modifyvm", :id,] + customizations) unless customizations.empty?

      config.vm.share_folder "v-cache",
                             "/var/cache/apt/archives/",
                             local_cache(config.vm.box)

      options[:shares].each_pair do |guest_directory, host_directory|
        config.vm.share_folder guest_directory.gsub('/', '-'), guest_directory, host_directory
      end if options[:shares]

      options[:forwards].each_pair do |guest_port, forward_config|
        host_port = forward_config.is_a?(Hash) ? forward_config[:port] : forward_config
        forward_options = forward_config.is_a?(Hash) ? forward_config.dup : {}
        forward_options.delete_if {|key, value| key == :port }
        config.vm.forward_port guest_port, host_port, forward_options
      end if options[:forwards]

      if (options[:recipes] && options[:recipes] != []) || (options[:roles] && options[:roles] != [])
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
        config.vm.provision :chef_solo do |chef|
          chef.cookbooks_path = ["cookbooks"]
          chef.roles_path = "roles"
          chef.data_bags_path = "data_bags"
          chef.json = options[:json] if options[:json]
          options[:recipes].each do |recipe|
            chef.add_recipe(recipe)
          end if options[:recipes]
          options[:roles].each do |role|
            chef.add_role(role)
          end if options[:roles]
        end
      end
    end
  end
end
