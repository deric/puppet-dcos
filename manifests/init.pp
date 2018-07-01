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
#
# [*bootstrap_script*]
#   Script to be fetched from bootstrap node. Default: `dcos_install.sh`
#
# [*download_dir*]
#   Directory where `bootstrap_script` will be stored.
#
# [*install_checksum*]
#   A hash with `bootstrap_script` checksums. E.g.:
#   ```
#   class{'::dcos':
#     bootstrap_url: 'http://localhost:9090',
#     install_checksum => {
#        type => 'sha1',
#        hash => 'aaabbb...'
#     },
#   }
#   ```
#
class dcos (
  $bootstrap_url    = undef,
  $bootstrap_script = $::dcos::params::bootstrap_script,
  $download_dir     = $::dcos::params::download_dir,
  $install_checksum = $::dcos::params::install_checksum,
  $region           = undef,
  $zone             = undef
) inherits ::dcos::params {

  include ::dcos::install
  include ::dcos::config

  Class['::dcos::install']
  -> Class['::dcos::config']
  -> Class['::dcos']
}
