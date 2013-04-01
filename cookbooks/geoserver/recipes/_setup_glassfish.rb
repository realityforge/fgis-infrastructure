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

domain = node['geoserver']['glassfish']['domain']

node.override['glassfish']['domains'][domain]['config']['jvm_options'] = %w(-DGEOSERVER_DATA_DIR=#{node['geoserver']['data_dir']})
node.override['glassfish']['domains'][domain]['deployables']['geoserver']['url'] = "file://#{node['geoserver']['base_dir']}/geoserver.war"
node.override['glassfish']['domains'][domain]['deployables']['geoserver']['context_root'] = node['geoserver']['glassfish']['root']
