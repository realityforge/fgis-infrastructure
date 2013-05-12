maintainer       "Opscode, Inc."
maintainer_email "cookbooks@opscode.com"
license          "Apache 2.0"
description      "Installs/Configures tomcat"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.12.10"

depends 'java'

supports 'ubuntu'

recipe "tomcat::default", "Installs and configures Tomcat"
