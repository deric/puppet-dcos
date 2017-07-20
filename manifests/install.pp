# == Class dcos::install
#
# This class is called from dcos for install.
#
class dcos::install {

  package { $::dcos::package_name:
    ensure => present,
  }
}
