# == Class dcos::os::debian
#
# WARNING: Debian is not officially supported, not everything is guaranteed to work!

class dcos::os::debian {
  ensure_packages(['libcurl3-nss','ipset','selinux-utils','curl','unzip','bc','tar','ipvsadm','xz-utils'])

  # libraries dynamically linked to mesos:
  ensure_packages(['libsvn1','libapr1','libunwind8'])

  # systemd services have hardcoded paths, we need to ensure
  # the same paths as on RedHat systems
  file { '/usr/bin/bash':
    ensure  => link,
    target  => '/bin/bash',
    replace => false,
  }

  file { '/usr/bin/rm':
    ensure  => link,
    target  => '/bin/rm',
    replace => false,
  }

  file { '/usr/bin/tar':
    ensure  => link,
    target  => '/bin/tar',
    replace => false,
  }

  file { '/usr/bin/mkdir':
    ensure  => link,
    target  => '/bin/mkdir',
    replace => false,
  }

  file { '/usr/bin/ln':
    ensure  => link,
    target  => '/bin/ln',
    replace => false,
  }

  file { '/sbin/useradd':
    ensure  => link,
    target  => '/usr/sbin/useradd',
    replace => false,
  }

  file { '/usr/sbin/ipset':
    ensure  => link,
    target  => '/sbin/ipset',
    replace => false,
  }
}
