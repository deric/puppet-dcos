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

  if $::dcos::bootstrap_url {
    include '::archive'
    $download_url = "${::dcos::bootstrap_url}/${::dcos::bootstrap_script}"

    archive { "${::dcos::download_dir}/dcos_install.sh":
      ensure        => present,
      user          => 'root',
      group         => 'root',
      source        => $download_url,
      checksum      => $::dcos::install_checksum['hash'],
      checksum_type => $::dcos::install_checksum['type'],
      creates       => "${::dcos::download_dir}/dcos_install.sh",
      extract       => false,
      cleanup       => false,
      require       => Anchor['dcos::install::begin'],
    }
    Archive["${::dcos::download_dir}/dcos_install.sh"]
    -> Anchor['dcos::install::end']

  }

  anchor { 'dcos::install::end': }
}
