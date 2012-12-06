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

node.override['locale']['lang'] = "en_AU.UTF-8"

pg_hba = [
  {:type => 'local', :db => 'all', :user => 'postgres', :addr => nil, :method => 'ident'},
  {:type => 'local', :db => 'all', :user => 'all', :addr => nil, :method => 'ident'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '127.0.0.1/32', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '127.0.0.1/32', :method => 'md5'},
]

if node['gis'] && node['gis']['app_server_addresses']
  node['gis']['app_server_addresses'].each do |address|
    pg_hba << {:type => 'host', :db => 'all', :user => 'all', :addr => "#{address}/8", :method => 'md5'}
  end
end

node.override['postgresql']['pg_hba'] = pg_hba
node.override['postgresql']['password']['postgres'] = 'Open_Sesame'
node.override['postgresql']['config']['ssl'] = false
node.override['postgresql']['config']['listen_addresses'] = '0.0.0.0'

include_recipe 'apt::default'
include_recipe 'locale::default'
include_recipe 'postgis::default'
