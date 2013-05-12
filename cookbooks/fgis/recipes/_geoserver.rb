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

node.override['geoserver']['user'] = node.override['glassfish']['domains'][node['geoserver']['glassfish']['domain']]['config']['system_user']
node.override['geoserver']['group'] = node.override['glassfish']['domains'][node['geoserver']['glassfish']['domain']]['config']['system_group']

node.override['geoserver']['git']['config_repository'] = nil#'git://github.com/rhok-melbourne/fgis-geoserver.git'
node.override['geoserver']['users']['admin']['password'] = 'geoserver'
node.override['geoserver']['users']['admin']['role'] = 'ROLE_ADMINISTRATOR'

include_recipe 'geoserver::default'
