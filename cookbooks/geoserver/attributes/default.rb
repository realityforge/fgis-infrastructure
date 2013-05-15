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

default['geoserver']['user'] = nil
default['geoserver']['group'] = nil

version = '2.3.1'
default['geoserver']['version'] = version
default['geoserver']['package_url'] = "http://downloads.sourceforge.net/geoserver/geoserver-#{version}-war.zip"

default['geoserver']['base_dir'] = '/srv/geoserver'
default['geoserver']['data_dir'] = '/srv/geoserver/data'

default['geoserver']['git']['config_repository'] = nil
default['geoserver']['git']['reference'] = 'master'

default['geoserver']['glassfish']['domain'] = nil
default['geoserver']['glassfish']['root'] = '/geoserver'

default['geoserver']['users'] = Mash.new

default['geoserver']['tomcat']['instance'] = nil
default['geoserver']['tomcat']['root'] = '/geoserver'
