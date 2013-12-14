# Description

[![Build Status](https://secure.travis-ci.org/realityforge/chef-tomcat.png?branch=master)](http://travis-ci.org/realityforge/chef-tomcat)

The tomcat cookbook installs and configures the Tomcat application server. The cookbook contains LWRPs to create
and configure Tomcat instances and deploy resources into the container.

# Requirements

## Platform:

* Ubuntu

## Cookbooks:

* java
* archive
* cutlery
* authbind (Suggested but not required)

# Attributes

* `node['tomcat']['user']` - Tomcat User: The user that owns the Tomcat binaries. Defaults to `tomcat`.
* `node['tomcat']['group']` - Tomcat Admin Group: The group allowed to manage Tomcat domains. Defaults to `tomcat-admin`.
* `node['tomcat']['package_url']` - URL for Package: The url to the Tomcat zip install package. Defaults to `nil`.
* `node['tomcat']['base_dir']` - Tomcat Base Directory: The base directory of the Tomcat install. Defaults to `/usr/local/tomcat`.
* `node['tomcat']['instances_dir']` - Tomcat Instance Directory: The directory containing all the instances. Defaults to `/srv/tomcat`.
* `node['tomcat']['instances']` - Tomcat Instance Definitions: A map of instance definitions used by the attribute_driven recipe. Defaults to `Mash.new`.

# Recipes

* [tomcat::attribute_driven](#tomcatattribute_driven) - Configures 0 or more Tomcat instances using the tomcat/instances attribute.
* [tomcat::default](#tomcatdefault) - Installs Tomcat binaries.

## tomcat::attribute_driven

Configures 0 or more Tomcat instances using the tomcat/instances attribute.

## tomcat::default

Installs Tomcat binaries.

Downloads, and extracts the tomcat binaries, creates the tomcat user and group.

# Resources

* [tomcat_instance](#tomcat_instance) - Creates a Tomcat instance, creates an OS-level service and starts the service.
* [tomcat_webapp](#tomcat_webapp) - Creates a Tomcat instance, creates an OS-level service and starts the service.

## tomcat_instance

Creates a Tomcat instance, creates an OS-level service and starts the service.

### Actions

- create: Create the instance, enable and start the associated service. Default action.
- destroy: Stop the associated service and delete the instance directory and associated artifacts.

### Attribute Parameters

- min_memory:  Defaults to <code>512</code>.
- max_memory: The amount of heap memory to allocate to the domain in MiB. Defaults to <code>512</code>.
- max_perm_size: The amount of perm gen memory to allocate to the domain in MiB. Defaults to <code>96</code>.
- max_stack_size: The amount of stack memory to allocate to the domain in KiB. Defaults to <code>256</code>.
- http_port: The port on which the HTTP service will bind. Defaults to <code>8080</code>.
- ajp_port: The port on which the AJP service will bind. Defaults to <code>8009</code>.
- ssl_port: The port on which the SSL service will bind. Defaults to <code>8443</code>.
- shutdown_port: The port which used to shutdown the instance. Defaults to <code>8005</code>.
- extra_jvm_options: An array of extra arguments to pass the JVM. Defaults to <code>[]</code>.
- env_variables: A hash of environment variables set when running the domain. Defaults to <code>{}</code>.
- instance_name: The name of the tomcat instance.
- logging_properties: A hash of properties that will be merged into logging.properties. Use this to send logs to syslog or graylog. Defaults to <code>{}</code>.
- system_user: The user that the domain executes as. Defaults to `node['glassfish']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['glassfish']['group']` if unset. Defaults to <code>nil</code>.

### Examples

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

## tomcat_webapp

Creates a Tomcat instance, creates an OS-level service and starts the service.

### Actions

- create: Create the web application. Default action.
- destroy: Destroy the web application.

### Attribute Parameters

- webapp_name: The name of the web application.
- version: The version of the war file. Defaults to <code>nil</code>.
- url: The url of the war file. Defaults to <code>nil</code>.
- path: The url path under which to register web application. Defaults to <code>nil</code>.
- unpack_war:  Defaults to <code>"false"</code>.
- instance_name: The name of the tomcat instance.
- system_user: The user that the domain executes as. Defaults to `node['tomcat']['user']` if unset. Defaults to <code>nil</code>.
- system_group: The group that the domain executes as. Defaults to `node['tomcat']['group']` if unset. Defaults to <code>nil</code>.

### Examples

    tomcat_webapp "my_application" do
      version '1.2'
      url 'http://example.com/my_application-1.2.war']
      instance 'my_app_domain'
      system_user 'tomcat'
      system_group 'tomcat'
    end

# License and Maintainer

Maintainer:: Peter Donald

License:: Apache 2.0
