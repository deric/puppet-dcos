# == Class dcos::params
#
# This class is meant to be called from dcos.
# It sets variables according to platform.
#
class dcos::params {
  case $::osfamily {
    'Debian': {
      $package_name = 'dcos'
      $service_name = 'dcos'
    }
    'RedHat', 'Amazon': {
      $package_name = 'dcos'
      $service_name = 'dcos'
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
