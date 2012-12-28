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

#Hmmm ... 2.2.4 does not seem to work in glassfish?
#package_url = 'http://downloads.sourceforge.net/geoserver/geoserver-2.2.2-war.zip'
package_url = 'http://downloads.sourceforge.net/geoserver/geoserver-2.1.4-war.zip'
base_package_filename = File.basename(package_url)
cached_package_filename = "#{Chef::Config[:file_cache_path]}/#{base_package_filename}"

check_proc = Proc.new { ::File.exists?("#{Chef::Config[:file_cache_path]}/geoserver.war") }

remote_file cached_package_filename do
  source package_url
  mode '0600'
  action :create_if_missing
  not_if { check_proc.call }
end

package 'unzip'

bash 'unpack_geoserver' do
  code <<-EOF
cd #{Chef::Config[:file_cache_path]}
unzip -qq #{cached_package_filename} geoserver.war
chown #{node['glassfish']['user']}:#{node['glassfish']['group']} geoserver.war
test -f geoserver.war
  EOF
  not_if { check_proc.call }
end

node.override['glassfish']['base_dir'] = '/usr/local/glassfish'
node.override['glassfish']['domains_dir'] = '/usr/local/glassfish/glassfish/domains'

include_recipe 'glassfish::default'

directory '/srv/geoserver' do
  owner node['glassfish']['user']
  group node['glassfish']['group']
  mode 0700
  recursive true
end

package 'git'

geo_data = '/srv/geoserver/data'
git geo_data do
  repository node['fgis']['geoserver']['repository']
  reference node['fgis']['geoserver']['reference']
  user node['glassfish']['user']
  group node['glassfish']['group']
  action :sync
end

template "#{geo_data}/security/users.properties" do
  source 'users.properties.erb'
  mode 0700
  user node['glassfish']['user']
  group node['glassfish']['group']
  variables(:users => [['admin','geoserver','ROLE_ADMINISTRATOR']])
end

node.override['glassfish']['domains']['geo'] =
  {
    'config' => {
      'min_memory' => 412,
      'max_memory' => 512,
      'max_perm_size' => 200,
      'port' => 80,
      'admin_port' => 8085,
      'max_stack_size' => 200,
      'username' => 'geo_admin',
      'password' => 'G3TzM3Inith!PLZ',
      'remote_access' => 'true',
      'jvm_options' => ["-DGEOSERVER_DATA_DIR=#{geo_data}"]
    },
    'properties' => {
      'configs.config.server-config.admin-service.das-config.autodeploy-enabled' => 'false',
      'configs.config.server-config.admin-service.das-config.dynamic-reload-enabled' => 'false'
    },
    'extra_libraries' => {
      'postgresql' => 'http://jdbc.postgresql.org/download/postgresql-9.2-1002.jdbc4.jar'
    },
    'jdbc_connection_pools' => {
      'GeoServerPool' => {
        'config' => {
          'datasourceclassname' => 'org.postgresql.ds.PGConnectionPoolDataSource',
          'restype' => 'javax.sql.ConnectionPoolDataSource',
          'isconnectvalidatereq' => 'true',
          'validationmethod' => 'auto-commit',
          'ping' => 'true',
          'description' => 'GeoServer Connection Pool',
          'properties' => {
            'databaseName' => node['fgis']['database']['db_name'],
            'user' => node['fgis']['database']['username'],
            'password' => node['fgis']['database']['password'],
            'serverName' => '127.0.0.1',
            'portNumber' => '5432',
          }
        },
        'resources' => {
          'jdbc/GeoServer' => {
            'description' => 'GeoServer Connection Resource'
          }
        }
      }
    },
    'deployables' => {
      'geoserver' => {
        'url' => "file://#{Chef::Config[:file_cache_path]}/geoserver.war",
        'context_root' => '/geoserver'
      },
      'fgis' => {
        'url' => 'https://github.com/realityforge/repository/raw/master/org/realityforge/fgis/fgis/0.1/fgis-0.1.war',
        'context_root' => '/fgis'
      }
    },
  }

include_recipe 'glassfish::attribute_driven_domain'
