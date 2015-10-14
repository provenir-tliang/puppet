## site.pp ##

# This file (/etc/puppetlabs/puppet/manifests/site.pp) is the main entry point
# used when an agent connects to a master and asks for an updated configuration.
#
# Global objects like filebuckets and resource defaults should go in this file,
# as should the default node definition. (The default node can be omitted
# if you use the console and don't define any other nodes in site.pp. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.)

## Active Configurations ##

# PRIMARY FILEBUCKET
# This configures puppet agent and puppet inspect to back up file contents when
# they run. The Puppet Enterprise console needs this to display file contents
# and differences.

# Define filebucket 'main':
filebucket { 'main':
  server => 'puppet.provapps.com',
  path   => false
}

# Make filebucket 'main' the default backup location for all File resources:
File { backup => 'main' }

# DEFAULT NODE
# Node definitions in this file are merged with node data from the console. See
# http://docs.puppetlabs.com/guides/language_guide.html#nodes for more on
# node definitions.

# The default node definition matches any node lacking a more specific node
# definition. If there are no other nodes in this file, classes declared here
# will be included in every node's catalog, *in addition* to any classes
# specified in the console for that node.

import "nodes"

node default {
  # This is where you can declare classes for all nodes.
  # Example:
  #   class { 'my_class': }
  hiera_include('classes', '')
}

class os_base {
  case $::operatingsystem {
    redhat,centos: {
      include linux_basenode
      include ia32-libs
      include s3backup
#      include nfs_home_dirs
#      class { 'authconfig':
#        ldapserver => 'ip-10-190-190-104.ec2.internal:3389'
#      }
    }
  }
}

class commercial_app_provenir_7_admin_only (
  $base_dir = '/opt/Provenir',
  $jar_level = 'released' #development,released, or custom
  ){
  class {'provenir':
    version      => '7',
    base_dir     => "$commercial_app_provenir_7_admin_only::base_dir"
  }
}

class commercial_app_provenir_7 (
  $port   = '6080',
  $url    = '/ProvAppCLWeb',
  $base_dir = '/opt/Provenir',
  $jar_level = 'released' #development,released, or custom
  ){
  class {'provenir':
    version      => '7',
    jms_provider => 'openjms',
    base_dir     => "$base_dir",
    jar_level    => "$jar_level"
  }
  notice ("including commercial_app_base")
  include commercial_app_base
  provenir::repository::repo_web_app { 'provenir-repo':
    app_server   => 'tomcat6',
    tomcat_home  => '/usr/share/tomcat6',
    web_app      => 'Repository70.war'
  }
  commercial_app_http_check { "$hostname-http":
    port         => "$port",
    url          => "$url"
  }
}

class commercial_app_provenir_6 (
  $port   = '6080',
  $url    = '/ProvAppCommercialWeb/'
  ){
  class {'provenir':
    version      => '6',
    release      => '6.0.3',
    jms_provider => 'openjms'
  }
  include commercial_app_base
  provenir::repository::repo_web_app { 'provenir-repo':
    app_server   => 'tomcat6',
#    web_app_path => '/var/lib/tomcat6/webapps',
    web_app      => 'Repository60.war'
  }
  commercial_app_http_check { "$hostname-http":
    port         => "$port",
    url          => "$url"
  }
}

class commercial_app_base {
  include openjms
  class { 'tomcat': }
  include jackrabbit
  include oracle_sqlplus
  include provenir::admin_server
  include provenir::repository
  include provenir::configs
  include commercial_app::nagios
}

class network_tools {
  include netcat
  include telnet
  include bind_utils
#  include wget
}

class smtp_server {
  include postfix
}

#class nfs_home_dirs {
#  include nfsclient
#  class { "autofs":
#    nfshomedirserver => 'ip-10-190-190-104.ec2.internal'
#  }
#}

class central_auth {
  include nfsclient
  class { "autofs":
    nfshomedirserver => 'puppet.provapps.com'
  }
  class { 'authconfig':
    ldapserver => 'puppet.provapps.com:3389',
  }
}

class utilities {
  include python::ldap::install
  include unzip
  include sysstat
  include man
  include sudo
  include dos2unix
}

class java_node {
  include java
}

class linux_basenode {
  include user
  include ssh
  include ntp
  include snmp
  include etc_hosts
  include java
  include emacs
  include screen
  include base_permissions
  include network_tools
  include utilities
  include iptables
  include nagios::target
  include smtp_server
  include user::unixadmins
#  include monit
}
