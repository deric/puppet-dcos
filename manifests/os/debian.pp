# == Class dcos::os::debian
#
# WARNING: Debian is not officially supported, not everything is guaranteed to work!

class dcos::os::debian {
  ensure_packages(['libcurl3-nss','ipset','selinux-utils','curl','unzip','bc','tar'])

  # systemd services have hardcoded paths, we need to ensure
  # the same paths as on RedHat systems
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

  file { '/usr/sbin/ipset':
    ensure => link,
    target => '/sbin/ipset',
  }
}