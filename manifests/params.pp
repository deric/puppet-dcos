# == Class dcos::params
#
# This class is meant to be called from dcos.
# It sets variables according to platform.
#
class dcos::params {
  $bootstrap_script = 'dcos_install.sh'
  $download_dir = '/tmp/dcos'
}
