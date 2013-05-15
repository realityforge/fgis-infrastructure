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

instance_name = node['geoserver']['tomcat']['instance']

node.override['tomcat']['instances'][instance_name]['config']['jvm_options'] = %W(-DGEOSERVER_DATA_DIR=#{node['geoserver']['data_dir']})
node.override['tomcat']['instances'][instance_name]['config']['system_user'] = node['geoserver']['user']
node.override['tomcat']['instances'][instance_name]['config']['system_group'] = node['geoserver']['group']
node.override['tomcat']['instances'][instance_name]['webapps']['geoserver']['url'] = "file://#{node['geoserver']['base_dir']}/geoserver-#{node['geoserver']['version']}.war"
node.override['tomcat']['instances'][instance_name]['webapps']['geoserver']['version'] = node['geoserver']['version']
node.override['tomcat']['instances'][instance_name]['webapps']['geoserver']['path'] = node['geoserver']['glassfish']['root']
node.override['tomcat']['instances'][instance_name]['webapps']['geoserver']['unpack_war'] = 'true'
