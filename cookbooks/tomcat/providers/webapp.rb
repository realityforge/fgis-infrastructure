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

require 'digest/sha1'

def instance_dir_path
  "#{node['tomcat']['instances_dir']}/#{new_resource.instance_name}"
end

use_inline_resources

action :create do
  raise "Must specify url" unless new_resource.url

  version = new_resource.version ? new_resource.version.to_s : Digest::SHA1.hexdigest(new_resource.url)
  path = new_resource.path ? new_resource.path.to_s : "/#{new_resource.webapp_name}"

  a = archive new_resource.webapp_name do
    prefix "#{instance_dir_path}/applications"
    url new_resource.url
    version version
    owner new_resource.system_user
    group new_resource.system_group
    extract_action 'unzip' if new_resource.unpack_war.to_s == "true"
  end

  service "tomcat-#{new_resource.instance_name}" do
    provider Chef::Provider::Service::Upstart
    supports :start => true, :restart => true, :stop => true, :status => true
    action :nothing
  end

  template "#{instance_dir_path}/conf/Catalina/localhost/#{new_resource.webapp_name}.xml" do
    source "context.xml.erb"
    mode "0600"
    cookbook 'tomcat'
    owner new_resource.system_user
    group new_resource.system_group
    variables(:resource => new_resource, :war_file => a.target_artifact, :path => path)
    notifies :restart, "service[tomcat-#{new_resource.instance_name}]", :delayed
  end
end

action :destroy do
  service "tomcat-#{new_resource.instance_name}" do
    provider Chef::Provider::Service::Upstart
    supports :start => true, :restart => true, :stop => true, :status => true
    action :nothing
  end

  directory "#{instance_dir_path}/applications/#{new_resource.instance_name}" do
    recursive true
    action :delete
  end

  file "#{instance_dir_path}/webapps/#{new_resource.webapp_name}.xml" do
    action :delete
    notifies :restart, "service[tomcat-#{new_resource.instance_name}]", :delayed
  end
end
