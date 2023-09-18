# == Class dcos::params
#
# This class is meant to be called from dcos.
# It sets variables according to platform.
#
class dcos::params {
  $bootstrap_script = 'dcos_install.sh'
  $download_dir = '/tmp/dcos'
  $install_checksum = {
    'hash' => undef,
    'type' => undef,
  }
  case $facts['os']['family'] {
    'Debian': {
      $executor = {
        'PATH' => '/usr/bin:/bin',
        'SHELL' => '/usr/bash',
        'LIBPROCESS_NUM_WORKER_THREADS' => '8',
      }
    }
    'RedHat', 'Amazon': {
      $executor = {
        'PATH' => '/usr/bin:/bin',
        'SHELL' => '/usr/bin/bash',
        'LIBPROCESS_NUM_WORKER_THREADS' => '8',
      }
    }
    default: {
      $executor = {}
    }
  }
}
