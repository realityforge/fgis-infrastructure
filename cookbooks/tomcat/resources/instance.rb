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

@action create  Create the instance, enable and start the associated service.
@action destroy Stop the associated service and delete the instance directory and associated artifacts.

@section Examples

    # Create a basic tomcat instance that logs to a central graylog server
    tomcat_instance "my_domain" do
      http_port 80
      extra_libraries ['https://github.com/downloads/realityforge/gelf4j/gelf4j-0.9-all.jar']
      logging_properties {
        "handlers" => "java.util.logging.ConsoleHandler, gelf4j.logging.GelfHandler",
        ".level" => "INFO",
        "java.util.logging.ConsoleHandler.level" => "INFO",
        "gelf4j.logging.GelfHandler.level" => "ALL",
        "gelf4j.logging.GelfHandler.host" => 'graylog.example.org',
        "gelf4j.logging.GelfHandler.defaultFields" => '{"environment": "' + node.chef_environment + '", "facility": "MyDomain"}'
      }
    end
#>
=end

actions :create, :destroy

#<> @attribute The minimum memory to allocate to the domain in MiB.
attribute :min_memory, :kind_of => Integer, :default => 512
#<> @attribute max_memory The amount of heap memory to allocate to the domain in MiB.
attribute :max_memory, :kind_of => Integer, :default => 512
#<> @attribute max_perm_size The amount of perm gen memory to allocate to the domain in MiB.
attribute :max_perm_size, :kind_of => Integer, :default => 96
#<> @attribute max_stack_size The amount of stack memory to allocate to the domain in KiB.
attribute :max_stack_size, :kind_of => Integer, :default => 256
#<> @attribute http_port The port on which the HTTP service will bind.
attribute :http_port, :kind_of => Integer, :default => 8080
#<> @attribute ajp_port The port on which the AJP service will bind.
attribute :ajp_port, :kind_of => Integer, :default => 8009
#<> @attribute ssl_port The port on which the SSL service will bind.
attribute :ssl_port, :kind_of => Integer, :default => 8443
#<> @attribute shutdown_port The port which used to shutdown the instance.
attribute :shutdown_port, :kind_of => Integer, :default => 8005
#<> @attribute extra_jvm_options An array of extra arguments to pass the JVM.
attribute :extra_jvm_options, :kind_of => Array, :default => []
#<> @attribute env_variables A hash of environment variables set when running the domain.
attribute :env_variables, :kind_of => Hash, :default => {}

#<> @attribute instance_name The name of the tomcat instance.
attribute :instance_name, :kind_of => String, :name_attribute => true
#<> @attribute logging_properties A hash of properties that will be merged into logging.properties. Use this to send logs to syslog or graylog.
attribute :logging_properties, :kind_of => Hash, :default => {}

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

