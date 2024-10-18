# == Class dcos::install
#
# This class is called from dcos for install.
#
class dcos::install {
  file { '/usr/local/bin/dcos-version':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/dcos/dcos-version',
  }

  # prerequisities
  case $facts['os']['family'] {
    'Debian': {
      contain dcos::os::debian
    }
    'RedHat', 'Amazon': {
      contain dcos::os::redhat
    }
    default: {
      fail("${facts['os']['family']} not supported")
    }
  }

  if $dcos::bootstrap_url {
    $download_url = "${dcos::bootstrap_url}/${dcos::bootstrap_script}"

    file { $dcos::download_dir:
      ensure  => directory,
      recurse => true,
      owner   => 'root',
      group   => 'root',
    }

    archive { "${dcos::download_dir}/dcos_install.sh":
      ensure        => present,
      user          => 'root',
      group         => 'root',
      source        => $download_url,
      creates       => "${dcos::download_dir}/dcos_install.sh",
      extract       => false,
      cleanup       => false,
      checksum      => $dcos::install_checksum['hash'],
      checksum_type => $dcos::install_checksum['type'],
      require       => File[$dcos::download_dir],
    }
  }
}
