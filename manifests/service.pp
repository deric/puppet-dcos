# == Class dcos::service
#
# This class is meant to be called from dcos.
# It ensure the service is running.
#
class dcos::service {

  service { $::dcos::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
