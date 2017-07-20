# Class: dcos
# ===========================
#
# Manages DC/OS nodes, ensures compatibility between distributions
#

class dcos (

) inherits ::dcos::params {

  class { '::dcos::install': } ->
  class { '::dcos::config': } ->
  Class['::dcos']
}
