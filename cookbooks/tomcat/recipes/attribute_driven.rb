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

include_recipe 'tomcat::default'

node['tomcat']['instances'].each_pair do |instance_name, definition|
  instance_name = instance_name.to_s

  Chef::Log.info "Defining Tomcat Instance #{instance_name}"

  config = definition['config'] || {}

  http_port = config['http_port']
  ajp_port = config['ajp_port']
  ssl_port = config['ssl_port']

  system_username = config['system_user']
  system_group = config['system_group']

  if (http_port && http_port < 1024) || (ajp_port && ajp_port < 1024) || (ssl_port && ssl_port < 1024)
    include_recipe 'authbind'
  end

  tomcat_instance instance_name do
    min_memory config['min_memory'] if config['min_memory']
    max_memory config['max_memory'] if config['max_memory']
    max_perm_size config['max_perm_size'] if config['max_perm_size']
    max_stack_size config['max_stack_size'] if config['max_stack_size']
    http_port http_port if http_port
    ajp_port ajp_port if ajp_port
    ssl_port ssl_port if ssl_port
    shutdown_port config['shutdown_port'] if config['shutdown_port']
    logging_properties definition['logging_properties'] if definition['logging_properties']
    extra_jvm_options config['jvm_options'] if config['jvm_options']
    env_variables config['environment'] if config['environment']
    system_user system_username if system_username
    system_group system_group if system_group
  end
end

instance_names = node['tomcat']['instances'].keys

Dir["#{node['tomcat']['instances_dir']}/*"].
  select { |file| File.directory?(file) }.
  select { |file| !instance_names.include?(File.basename(file)) }.
  each do |file|

  Chef::Log.info "Removing historic Tomcat Instance #{File.basename(file)}"

  tomcat_instance File.basename(file) do
    action :destroy
  end
end
