# nodes.pp

node provappswebdev01,jpmc-web {
  include os_base
  include monit
#  include openjms
  include tomcat
#  include jackrabbit
  include monit::provappswebdev01::init
  include jackrabbit::monit::init
  include smtp_server
}

# this is a shared DB server.  please be careful with it.
node provappsdbdev01,jpmc-db {
#  include linux_basenode
  include ntp
  include snmp
  include etc_hosts
  include java
  include emacs
  include screen
  include base_permissions
  include network_tools
  include utilities
  include nagios::target
  include monit
  include s3backup
  include monit::provappsdbdev01::init
  include oracle::nagios
  oracle_listener_check { "provappsdbdev01-oracle-listener":
    sid  => 'orcl'
  }
  tidy { ["/opt/oracle/app/oracle/admin/orcl/adump",
          "/opt/oracle/app/oracle/product/11.2.0/dbhome_1/rdbms/log",
          "/opt/oracle/app/oracle/diag/rdbms/orcl/orcl/incident",
          "/opt/oracle/app/oracle/diag/rdbms/orcl/orcl/trace",
          "/tmp"]:
    age     => "7d",
    recurse => 1
  }
}

node env-base {
  include linux_basenode
  include utilities
  include java_node
  include openjms
}

node mtdemo {
  include os_base
  class { 'commercial_app_provenir_6': port => '7480' }
  include mysqld
  include mysqld::db::mtdemo_provmnt
}

node sbapoc {
  include os_base
  include mysqld
  include mysqld::db::sbapoc_provsba
  class { 'commercial_app_provenir_6':
    port         => '7280',
  }
  tidy { "/opt/sbapoc/glassfish3/glassfish/domains/domain1/logs":
    age     => "3d",
    recurse => 1
  }
}

#node horizondev,horizonqa {
#  include os_base
#  class { 'commercial_app_provenir_7':
#    jar_level    => 'dcs',
#  }
#}

node ip-10-40-126-55,ec2-50-16-39-216 {
  include os_base
  class { 'commercial_app_provenir_7':
    jar_level    => 'released'
  }
}

node "ip-10-110-71-209.ec2.internal" {
  include hiera_test
}

node "cloud_puppet.ec2.internal","horizondev",ec2-23-22-251-247 {
  hiera_include('classes', '')
#  include ia32-libs
#  include s3backup
#  include ssh
#  include ntp
#  include monit
#  include java
#  include emacs
#  include screen
#  include base_permissions
#  include network_tools
#  include nfsserver
#  class { 'authconfig':
#    ldapserver => 'ip-10-190-190-104.ec2.internal:3389',
#  }
}

node jpmc-demo {
  include os_base
  class { 'commercial_app_provenir_7':
    port         => '8080'
  }
}

node presales-demo1 {
     include os_base
     class { 'commercial_app_provenir_7': }
     include mysqld
     include mysqld::db::sbapoc_provsba
     include commercial_app::nagios
}


# this box is the nfs server among other things.
# please be careful with it.
node provappsengdev01 {
#  tidy { "/var/log/provenir":
#    age     => "1w",
#    recurse => 1,
#    matches => [ "*.log", "*.trc" ]
#  }
  include nfsserver
  include linux_basenode
  include s3backup
  include monit
  include authconfig
  include smtp_server
  include ssh::authorized_keys
  class { 'commercial_app_provenir_7_admin_only':
    base_dir  => '/opt/Provenir70/Provenir'
  }
}

node provappslb01,provappsdev01,provappsdmo01 {
  include os_base
}

node puppet {
  include os_base
  include nagios::monitor
}

node provwiki {
  include linux_basenode
  include s3backup
}

node derek-test {
  include os_base
}


node ip-10-40-100-61 {
  #include nagios::monitor
#   include user::virtual
  include authconfig
  include ssh::authorized_keys
  include linux_basenode
#  include openjms
#  include provenir
  class { 'commercial_app_provenir_7':
    port         => '8080'
  }
#  class { 'commercial_app_base':
#    port         => '8080'
#  }
}

node 'devbox' {
  file { '/etc/motd':
    content => "Puppet Power!\n",
  }
}
