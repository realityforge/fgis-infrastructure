#
# Copyright Peter Donald
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

#<> Tomcat User: The user that owns the Tomcat binaries.
default['tomcat']['user'] = 'tomcat'
#<> Tomcat Admin Group: The group allowed to manage Tomcat domains.
default['tomcat']['group'] = 'tomcat-admin'

#<> URL for Package: The url to the Tomcat zip install package
default['tomcat']['package_url'] = nil

#<> Tomcat Base Directory: The base directory of the Tomcat install.
default['tomcat']['base_dir'] = '/usr/local/tomcat'
#<> Tomcat Instance Directory: The directory containing all the instances.
default['tomcat']['instances_dir'] = '/srv/tomcat'
#<> Tomcat Instance Definitions: A map of instance definitions used by the attribute_driven recipe.
default['tomcat']['instances'] = Mash.new
