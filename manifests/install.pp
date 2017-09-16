# == Class dcos::install
#
# This class is called from dcos for install.
#
class dcos::install {

  file {'/usr/local/bin/dcos-version':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/dcos/dcos-version',
  }

  case $::osfamily {
    'Debian': {
        ensure_packages(['libcurl3-nss','ipset','selinux-utils','curl','unzip','bc','tar'])

        # systemd services have hardcoded paths, we need to ensure
        # same paths as on RedHat systems
        file { '/usr/bin/bash':
          ensure => link,
          target => '/bin/bash',
        }

        file { '/usr/bin/rm':
          ensure => link,
          target => '/bin/rm',
        }

        file { '/usr/bin/tar':
          ensure => link,
          target => '/bin/tar',
        }

        file { '/usr/bin/mkdir':
          ensure => link,
          target => '/bin/mkdir',
        }

        file { '/usr/bin/ln':
          ensure => link,
          target => '/bin/ln',
        }

        file { '/sbin/useradd':
          ensure => link,
          target => '/usr/sbin/useradd',
        }
    }
    'RedHat', 'Amazon': {
      ensure_packages(['tar','xz','unzip','curl','ipset'])
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
