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

pg_hba = [
  {:type => 'local', :db => 'all', :user => 'postgres', :addr => nil, :method => 'ident'},
  {:type => 'local', :db => 'all', :user => 'all', :addr => nil, :method => 'ident'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '127.0.0.1/32', :method => 'md5'},
  {:type => 'host', :db => 'all', :user => 'all', :addr => '127.0.0.1/32', :method => 'md5'},
]

node['fgis']['app_server_addresses'].each do |address|
  pg_hba << {:type => 'host', :db => 'all', :user => 'all', :addr => "#{address}/8", :method => 'md5'}
end

node.override['postgresql']['pg_hba'] = pg_hba
node.override['postgresql']['password']['postgres'] = 'Open_Sesame'
node.override['postgresql']['config']['ssl'] = false
node.override['postgresql']['config']['listen_addresses'] = '0.0.0.0'

include_recipe 'postgis::default'

include_recipe 'sqlshell::default'

jdbc_host_prefix = "jdbc:postgresql://#{node['fqdn']}:#{node['postgresql']['config']['port']}"
jdbc_url = "#{jdbc_host_prefix}/postgres"
jdbc_driver = 'org.postgresql.Driver'
jdbc_properties =
  {
    'user' => node['fgis']['database']['username'],
    'password' => node['fgis']['database']['password']
  }
admin_jdbc_properties =
  { 'user' => 'postgres', 'password' => node['postgresql']['password']['postgres'] }

sqlshell_pg_user "#{node['fgis']['database']['username']}3" do
  jdbc_url jdbc_url
  jdbc_driver jdbc_driver
  extra_classpath ['http://jdbc.postgresql.org/download/postgresql-9.2-1002.jdbc4.jar']
  jdbc_properties admin_jdbc_properties

  password node['fgis']['database']['password']
end

psql_database node['fgis']['database']['db_name'] do
  host node['fqdn']
  port node['postgresql']['config']['port']
  admin_username 'postgres'
  admin_password node['postgresql']['password']['postgres']
  owner node['fgis']['database']['username']
  template 'template_postgis'
end

psql_permission "#{node['fgis']['database']['username']}@#{node['fgis']['database']['db_name']} => all" do
  host node['fqdn']
  port node['postgresql']['config']['port']
  admin_username 'postgres'
  admin_password node['postgresql']['password']['postgres']
  username node['fgis']['database']['username']
  database node['fgis']['database']['db_name']
  permissions %w(ALL)
end

# This is a little open. I am basing the SQL on ...
# http://stackoverflow.com/questions/760210/how-do-you-create-a-read-only-user-in-postgresql
psql_exec "Grant #{node['fgis']['database']['username']} full access to database artifacts" do
  host node['fqdn']
  port node['postgresql']['config']['port']
  admin_username 'postgres'
  admin_password node['postgresql']['password']['postgres']
  dbname node['fgis']['database']['db_name']
  command <<-SQL
GRANT USAGE ON SCHEMA public TO "#{node['fgis']['database']['username']}";
GRANT ALL ON ALL TABLES IN SCHEMA public TO "#{node['fgis']['database']['username']}"
  SQL
end
