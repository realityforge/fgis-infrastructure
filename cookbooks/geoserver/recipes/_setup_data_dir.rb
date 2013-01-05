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

if node['geoserver']['git']['config_repository']
  package 'git'

  git node['geoserver']['data_dir'] do
    repository node['geoserver']['git']['config_repository']
    reference node['geoserver']['git']['reference']
    user node['geoserver']['user']
    group node['geoserver']['group']
    action :sync
  end
end

directory "#{node['geoserver']['data_dir']}/security" do
  owner node['geoserver']['user']
  group node['geoserver']['group']
  mode 0700
end

template "#{node['geoserver']['data_dir']}/security/users.properties" do
  source 'users.properties.erb'
  mode 0700
  user node['geoserver']['user']
  group node['geoserver']['group']
  variables(:users => node['geoserver']['users'])
end
