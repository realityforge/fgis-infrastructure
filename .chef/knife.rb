log_level                :info
log_location             STDOUT

cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["#{File.dirname(__FILE__)}/../cookbooks"]

cookbook_copyright       ENV['CHEF_COOKBOOK_COPYRIGHT']
cookbook_email           ENV['CHEF_COOKBOOK_AUTHOR']
cookbook_license         'Apache 2.0'
readme_format            'md'