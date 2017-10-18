# Class: dcos
# ===========================
#
# Manages DC/OS nodes, ensures compatibility between distributions
#
# === Parameters
#
# [*bootstrap_url*]
#   Bootstrap node address for the advanced installation.
#   See https://dcos.io/docs/1.10/installing/custom/advanced/

class dcos (
  $bootstrap_url    = undef,
  $bootstrap_script = $::dcos::params::bootstrap_script,
  $download_dir     = $::dcos::params::download_dir,
  $install_checksum = {},
) inherits ::dcos::params {

  include dcos::install

  Class['::dcos::install']
  -> class { '::dcos::config': }
  -> Class['::dcos']
}
