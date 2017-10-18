# Class: dcos
# ===========================
#
# Manages DC/OS nodes, ensures compatibility between distributions
#

class dcos (

) inherits ::dcos::params {

  include dcos::install

  Class['::dcos::install']
  -> class { '::dcos::config': }
  -> Class['::dcos']
}
