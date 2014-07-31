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

# address of app server if it is on a different node
node.default['fgis']['app_server_addresses'] = []

# postgis database configuration
node.default['fgis']['database']['db_name'] = 'fgis_db'
node.default['fgis']['database']['username'] = 'fgis'
node.default['fgis']['database']['password'] = 'secret'

include_recipe 'apt::default'

node.override['locale']['lang'] = 'en_AU.UTF-8'
include_recipe 'locale::default'

include_recipe 'fgis::_setup_database'

node.override['java']['oracle']['accept_oracle_download_terms'] = true
node.override['java']['install_flavor'] = 'oracle'
node.override['java']['jdk_version'] = '7'
include_recipe 'java::default'

node.override['geoserver']['user'] = 'fgis2'
node.override['geoserver']['group'] = 'fgis2'

include_recipe 'fgis::_glassfish'
#include_recipe 'fgis::_tomcat'
