#
# Copyright Peter Donald
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

=begin
#<
Downloads, and extracts the tomcat binaries, creates the tomcat user and group.
#>
=end

include_recipe 'java'

group node['tomcat']['group'] do
end

user node['tomcat']['user'] do
  comment 'Tomcat Server'
  gid node['tomcat']['group']
  home node['tomcat']['base_dir']
  shell '/bin/bash'
  system true
end

package_url = node['tomcat']['package_url']
base_package_filename = File.basename(package_url)
cached_package_filename = "#{Chef::Config[:file_cache_path]}/#{base_package_filename}"
check_proc = Proc.new { ::File.exists?(node['tomcat']['base_dir']) }

remote_file cached_package_filename do
  not_if { check_proc.call }
  source package_url
  mode '0600'
  action :create_if_missing
end

package 'unzip'

bash 'unpack_tomcat' do
  not_if { check_proc.call }
  code <<-EOF
rm -rf /tmp/tomcat
mkdir /tmp/tomcat
cd /tmp/tomcat
tar xzf #{cached_package_filename}
mkdir -p #{node['tomcat']['base_dir']}
mv apache-tomcat-#{node['tomcat']['version']}/lib #{node['tomcat']['base_dir']}/
mv apache-tomcat-#{node['tomcat']['version']}/bin #{node['tomcat']['base_dir']}/
rm -f #{node['tomcat']['base_dir']}/bin/*.bat
rm -rf mv apache-tomcat-#{node['tomcat']['version']}
chown -R #{node['tomcat']['user']} #{node['tomcat']['base_dir']}
chgrp -R #{node['tomcat']['group']} #{node['tomcat']['base_dir']}
chmod -R ugo-w #{node['tomcat']['base_dir']}
test -d #{node['tomcat']['base_dir']}
EOF
end
