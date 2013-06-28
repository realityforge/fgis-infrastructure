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

name             'tomcat'
maintainer       'Peter Donald'
maintainer_email 'peter@realityforge.org'
license          "Apache 2.0"
description      "Installs/Configures the tomcat application server"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.16.1"

depends 'java'
depends 'archive'
depends 'cutlery'

suggests 'authbind'

supports 'ubuntu'

recipe "tomcat::default", "Installs Tomcat binaries."
recipe "tomcat::attribute_driven", "Configures 0 or more Tomcat instances using the tomcat/instances attribute."



attribute 'tomcat/user',
  :display_name => 'Tomcat User',
  :description => 'The user that owns the Tomcat binaries',
  :type => 'string',
  :default => 'tomcat'

attribute 'tomcat/group',
  :display_name => 'Tomcat Admin Group',
  :description => 'The group allowed to manage Tomcat domains',
  :type => 'string',
  :default => 'tomcat-admin'

attribute 'tomcat/package_url',
  :display_name => 'URL for Tomcat Package',
  :description => 'The url to the Tomcat zip install package',
  :type => 'string'

attribute 'tomcat/base_dir',
  :display_name => 'Tomcat Base Directory',
  :description => 'The base directory of the Tomcat install',
  :type => 'string',
  :default => '/usr/local/tomcat'

attribute 'tomcat/instances_dir',
  :display_name => 'Tomcat Instance Directory',
  :description => 'The directory containing all the instances',
  :type => 'string',
  :default => '/srv/tomcat'

attribute 'tomcat/instances',
  :display_name => 'Tomcat Instance Definitions',
  :description => 'A map of instance definitions used by the attribute_driven recipe',
  :type => 'hash',
  :default => {}
