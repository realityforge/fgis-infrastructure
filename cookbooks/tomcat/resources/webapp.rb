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

=begin
#<
Creates a Tomcat instance, creates an OS-level service and starts the service.

@action create  Create the web application.
@action destroy Destroy the web application.

@section Examples

    tomcat_webapp "my_application" do
      version '1.2'
      url 'http://example.com/my_application-1.2.war']
      instance 'my_app_domain'
      system_user 'tomcat'
      system_group 'tomcat'
    end
#>
=end

actions :create, :destroy

#<> @attribute webapp_name The name of the web application.
attribute :webapp_name, :kind_of => String, :name_attribute => true
#<> @attribute version The version of the war file.
attribute :version, :kind_of => String, :default => nil
#<> @attribute url The url of the war file.
attribute :url, :kind_of => String, :default => nil
#<> @attribute path The url path under which to register web application.
attribute :path, :kind_of => String, :default => nil

attribute :unpack_war, :equal_to => [true, false, 'true', 'false'], :default => 'false'

#<> @attribute instance_name The name of the tomcat instance.
attribute :instance_name, :kind_of => String, :name_attribute => true
#<> @attribute system_user The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset.
attribute :system_user, :kind_of => String, :default => nil
#<> @attribute system_group The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset.
attribute :system_group, :kind_of => String, :default => nil

default_action :create

def initialize(*args)
  super
  @system_user = node['tomcat']['user']
  @system_group = node['tomcat']['group']
end
