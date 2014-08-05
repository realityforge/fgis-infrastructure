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

domain_name = 'geo2'
node.override['geoserver']['glassfish']['domain'] = domain_name

node.override['glassfish']['domains'][domain_name] =
  {
    'config' => {
      'min_memory' => 412,
      'max_memory' => 512,
      'max_perm_size' => 200,
      'port' => 80,
      'admin_port' => 8085,
      'max_stack_size' => 500,
      'username' => 'geo_admin',
      'password' => 'G3TzM3Inith!PLZ',
      'remote_access' => 'true'
    },
    'extra_libraries' => {
      'postgresql' => 'http://jdbc.postgresql.org/download/postgresql-9.2-1002.jdbc4.jar'
    },
    'iiop-listeners' => {},
    'threadpools' => {
      'thread-pool-1' => {
        'maxthreadpoolsize' => 200,
        'minthreadpoolsize' => 5,
        'idletimeout' => 900,
        'maxqueuesize' => 4096
      },
      'http-thread-pool' => {
        'maxthreadpoolsize' => 5,
        'minthreadpoolsize' => 5,
        'idletimeout' => 900,
        'maxqueuesize' => 4096
      },
      'admin-pool' => {
        'maxthreadpoolsize' => 50,
        'minthreadpoolsize' => 5,
        'maxqueuesize' => 256
      }
    },
    'context_services' => {
      'blah' => {
        'description' => 'My Description'
      }
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
      'fgis' => {
        'url' => 'https://github.com/realityforge/repository/raw/master/org/realityforge/fgis/fgis/0.3/fgis-0.3.war',
        'context_root' => '/fgis',
        'recipes' => {
          'before' => %w(fgis::_geoserver)
        }
      }
    },
  }

include_recipe 'geoserver::_setup_tomcat'
include_recipe 'glassfish::attribute_driven_domain'
