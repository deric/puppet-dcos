# == Class dcos::os::debian
#
# WARNING: Debian is not officially supported, not everything is guaranteed to work!

class dcos::os::debian {
  ensure_packages(['libcurl3-nss','ipset','selinux-utils','curl','unzip','bc','tar'])

  # make sure to try system library first
  file_line { 'update LD_PATH /opt/mesosphere/environment':
    path => '/opt/mesosphere/environment',
    line => 'LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/opt/mesosphere/lib',
    match   => '^LD_LIBRARY_PATH=*',
    replace => true,
  }
  # libraries dynamically linked to mesos:
  ensure_packages(['libsvn1','libapr1'])

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