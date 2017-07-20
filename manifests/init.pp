# Class: dcos
# ===========================
#
# Full description of class dcos here.
#
# Parameters
# ----------
#
# * `sample parameter`
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
class dcos (
  $package_name = $::dcos::params::package_name,
  $service_name = $::dcos::params::service_name,
) inherits ::dcos::params {

  # validate parameters here

  class { '::dcos::install': } ->
  class { '::dcos::config': } ~>
  class { '::dcos::service': } ->
  Class['::dcos']
}
