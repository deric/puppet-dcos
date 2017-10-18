# == Class dcos::install
#
# This class is called from dcos for install.
#
class dcos::install {

  anchor { 'dcos::install::begin': }

  file {'/usr/local/bin/dcos-version':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/dcos/dcos-version',
  }

  # prerequisities
  case $::osfamily {
    'Debian': {
      include dcos::os::debian
      Class['dcos::os::debian']
      -> Anchor['dcos::install::begin']
    }
    'RedHat', 'Amazon': {
      include dcos::os::redhat
      Class['dcos::os::redhat']
      -> Anchor['dcos::install::begin']
    }
    default: {
      fail("${::osfamily} not supported")
    }
  }

  anchor { 'dcos::install::end': }
}
