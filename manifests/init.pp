# Class: dcos
# ===========================
#
# Manages DC/OS nodes, ensures compatibility between distributions
#
# === Parameters
#
# @param bootstrap_url
#   Bootstrap node address for the advanced installation.
#   See https://dcos.io/docs/1.10/installing/custom/advanced/
#
# @param bootstrap_script
#   Script to be fetched from bootstrap node. Default: `dcos_install.sh`
#
# @param download_dir
#   Directory where `bootstrap_script` will be stored.
#
# @param install_checksum
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
# @param zone
# @param region
#
class dcos (
  Optional[String] $bootstrap_url    = undef,
  Optional[String] $bootstrap_script = $dcos::params::bootstrap_script,
  Optional[String] $download_dir     = $dcos::params::download_dir,
  Optional[Hash]   $install_checksum = $dcos::params::install_checksum,
  Optional[String] $region           = undef,
  Optional[String] $zone             = undef
) inherits dcos::params {
  include dcos::install
  include dcos::config

  Class['dcos::install']
  -> Class['dcos::config']
}
