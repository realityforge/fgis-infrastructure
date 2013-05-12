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

def instance_dir_path
  "#{node['tomcat']['instances_dir']}/#{new_resource.instance_name}"
end

def default_logging_properties
  {
    'handlers' => '1catalina.org.apache.juli.FileHandler, 2localhost.org.apache.juli.FileHandler, 3manager.org.apache.juli.FileHandler, 4host-manager.org.apache.juli.FileHandler, java.util.logging.ConsoleHandler',
    '.handlers' => '1catalina.org.apache.juli.FileHandler, java.util.logging.ConsoleHandler',
    '1catalina.org.apache.juli.FileHandler.level' => 'FINE',
    '1catalina.org.apache.juli.FileHandler.directory' => '${catalina.base}/logs',
    '1catalina.org.apache.juli.FileHandler.prefix' => 'catalina.',

    '2localhost.org.apache.juli.FileHandler.level' => 'FINE',
    '2localhost.org.apache.juli.FileHandler.directory' => '${catalina.base}/logs',
    '2localhost.org.apache.juli.FileHandler.prefix' => 'localhost.',

    '3manager.org.apache.juli.FileHandler.level' => 'FINE',
    '3manager.org.apache.juli.FileHandler.directory' => '${catalina.base}/logs',
    '3manager.org.apache.juli.FileHandler.prefix' => 'manager.',

    '4host-manager.org.apache.juli.FileHandler.level' => 'FINE',
    '4host-manager.org.apache.juli.FileHandler.directory' => '${catalina.base}/logs',
    '4host-manager.org.apache.juli.FileHandler.prefix' => 'host-manager.',

    'java.util.logging.ConsoleHandler.level' => 'FINE',
    'java.util.logging.ConsoleHandler.formatter' => 'java.util.logging.SimpleFormatter',

    'org.apache.catalina.core.ContainerBase.[Catalina].[localhost].level' => 'INFO',
    'org.apache.catalina.core.ContainerBase.[Catalina].[localhost].handlers' => '2localhost.org.apache.juli.FileHandler',

    'org.apache.catalina.core.ContainerBase.[Catalina].[localhost].[/manager].level' => 'INFO',
    'org.apache.catalina.core.ContainerBase.[Catalina].[localhost].[/manager].handlers' => '3manager.org.apache.juli.FileHandler',

    'org.apache.catalina.core.ContainerBase.[Catalina].[localhost].[/host-manager].level' => 'INFO',
    'org.apache.catalina.core.ContainerBase.[Catalina].[localhost].[/host-manager].handlers' => '4host-manager.org.apache.juli.FileHandler',
  }
end

def default_jvm_options
  [
    # Don't rely on the JVMs default encoding
    "-Dfile.encoding=UTF-8",

    # Tomcat should be headless by default
    "-Djava.awt.headless=true",

    "-Djava.util.logging.config.file=#{instance_dir_path}/conf/logging.properties",
    "-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager",

    #"-Djava.security.manager",
    #"-Djava.security.policy=#{instance_dir_path}/conf/catalina.policy",
    # Uncomment the following line to make the umask available when using the
    # org.apache.catalina.security.SecurityListener
    #"-Dorg.apache.catalina.security.SecurityListener.UMASK=`umask`",

    "-Djava.endorsed.dirs=#{instance_dir_path}/endorsed",
    #"-Djava.ext.dirs=#{node['java']['java_home']}/lib/ext:#{node['java']['java_home']}/jre/lib/ext:#{instance_dir_path}/lib/ext",
    "-Dcatalina.home=#{node['tomcat']['base_dir']}",
    "-Dcatalina.base=#{instance_dir_path}",
    "-Djava.io.tmpdir=#{instance_dir_path}/temp",

    # JVM options
    "-XX:MaxPermSize=#{new_resource.max_perm_size}m",
    #"-XX:PermSize=64m",
    "-Xss#{new_resource.max_stack_size}k",
    "-Xms#{new_resource.min_memory}m",
    "-Xmx#{new_resource.max_memory}m",
    "-XX:NewRatio=2",

      # Configuration to enable effective JMX management
    "-Djava.rmi.server.hostname=#{node['fqdn']}",
    "-Djava.net.preferIPv4Stack=true"
  ]
end

use_inline_resources

action :create do
  if new_resource.system_group != node['tomcat']['group']
    group new_resource.system_group do
    end
  end

  if new_resource.system_user != node['tomcat']['user']
    user new_resource.system_user do
      comment "GlassFish #{new_resource.instance_name} Domain"
      gid new_resource.system_group
      home "#{node['tomcat']['instances_dir']}/#{new_resource.instance_name}"
      shell '/bin/bash'
      system true
    end
  end

  requires_authbind = new_resource.http_port < 1024 || new_resource.ajp_port < 1024 || new_resource.ssl_port < 1024

  service "tomcat-#{new_resource.instance_name}" do
    provider Chef::Provider::Service::Upstart
    supports :start => true, :restart => true, :stop => true, :status => true
    action :nothing
  end

  args = default_jvm_options.dup
  args += new_resource.extra_jvm_options
  args << "-cp"
  args << "#{node['tomcat']['base_dir']}/bin/bootstrap.jar:#{node['tomcat']['base_dir']}/bin/tomcat-juli.jar"
  args << "org.apache.catalina.startup.Bootstrap"
  args << "start"

  template "/etc/init/tomcat-#{new_resource.instance_name}.conf" do
    source "upstart.conf.erb"
    mode "0644"
    cookbook 'tomcat'

    variables(:resource => new_resource, :args => args, :authbind => requires_authbind)
    notifies :restart, "service[tomcat-#{new_resource.instance_name}]", :delayed
  end

  authbind_port "AuthBind Tomcat Port #{new_resource.http_port}" do
    only_if { new_resource.http_port < 1024 }
    port new_resource.http_port
    user new_resource.system_user
  end

  authbind_port "AuthBind Tomcat Port #{new_resource.ssl_port}" do
    only_if { new_resource.ssl_port < 1024 }
    port new_resource.ssl_port
    user new_resource.system_user
  end

  authbind_port "AuthBind Tomcat Port #{new_resource.ajp_port}" do
    only_if { new_resource.ajp_port < 1024 }
    port new_resource.ajp_port
    user new_resource.system_user
  end

  directory node['tomcat']['instances_dir'] do
    owner node['tomcat']['user']
    group node['tomcat']['group']
    mode "0777"
    recursive true
  end

  [
    instance_dir_path,
    "#{instance_dir_path}/conf",
    "#{instance_dir_path}/logs",
    "#{instance_dir_path}/lib",
    "#{instance_dir_path}/lib/ext",
    "#{instance_dir_path}/temp",
    "#{instance_dir_path}/webapps"
  ].each do |dir|
    directory dir do
      owner new_resource.system_user
      group new_resource.system_group
      mode "0700"
      recursive true
    end
  end

  template "#{instance_dir_path}/conf/logging.properties" do
    source "logging.properties.erb"
    mode "0400"
    cookbook 'tomcat'
    owner new_resource.system_user
    group new_resource.system_group
    variables(:logging_properties => default_logging_properties.merge(new_resource.logging_properties))
    notifies :restart, "service[tomcat-#{new_resource.instance_name}]", :delayed
  end

  template "#{instance_dir_path}/conf/server.xml" do
    source "server.xml.erb"
    mode "0400"
    cookbook 'tomcat'
    owner new_resource.system_user
    group new_resource.system_group
    variables(:tomcat => new_resource)
    notifies :restart, "service[tomcat-#{new_resource.instance_name}]", :delayed
  end

  %w{catalina.policy catalina.properties context.xml tomcat-users.xml web.xml}.each do |tc_file|
    cookbook_file "#{instance_dir_path}/conf/#{tc_file}" do
      mode "0400"
      cookbook 'tomcat'
      owner new_resource.system_user
      group new_resource.system_group
      source tc_file
      action :create
    end
  end

  service "tomcat-#{new_resource.instance_name}" do
    action [:start]
  end
end

action :destroy do
  service "tomcat-#{new_resource.instance_name}" do
    provider Chef::Provider::Service::Upstart
    action [:stop, :disable]
  end

  directory instance_dir_path do
    recursive true
    action :delete
  end

  file "/etc/init/glassfish-#{new_resource.instance_name}.conf" do
    action :delete
  end
end
