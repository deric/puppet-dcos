# DC/OS master node
#
# @param mesos
# @param manage_adminrouter
# @param service_name
# @param adminrouter
# @param metrics
# @param region
# @param zone
class dcos::master (
  Hash             $mesos = {},
  Boolean          $manage_adminrouter = false,
  String           $service_name = 'dcos-mesos-master',
  Hash             $adminrouter = {},
  Hash             $metrics = {},
  Optional[String] $region = $dcos::region,
  Optional[String] $zone = $dcos::zone,
) inherits dcos {
  anchor { 'dcos::master::installed': }

  if $dcos::bootstrap_url {
    exec { 'dcos master install':
      command     => "bash ${dcos::download_dir}/dcos_install.sh master",
      path        => '/bin:/usr/bin:/usr/sbin',
      onlyif      => 'test -z "`ls -A /opt/mesosphere`"',
      refreshonly => false,
      before      => Anchor['dcos::master::installed'],
    }
  }

  case $facts['os']['family'] {
    'Debian': {
      # needed for DC/OS < 1.11
      # make sure to try system library first
      file_line { 'update LD_PATH /opt/mesosphere/environment':
        path    => '/opt/mesosphere/environment',
        line    => 'LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/opt/mesosphere/lib',
        match   => '^LD_LIBRARY_PATH=*',
        replace => true,
        require => Anchor['dcos::master::installed'],
      }
    }
    default: {}
  }

  if $manage_adminrouter {
    class { 'dcos::adminrouter':
      config  => $adminrouter,
      require => Anchor['dcos::master::installed'],
    }
  }

  file { '/opt/mesosphere/etc/mesos-master-extras':
    ensure  => 'file',
    content => template('dcos/master-extras.erb'),
    notify  => Service[$service_name],
  }

  if $region or $zone {
    file { '/var/lib/dcos/mesos-master-domain.json':
      ensure  => 'file',
      content => dcos::domain($region, $zone),
      notify  => Service[$service_name],
      require => Anchor['dcos::master::installed'],
    }
  }

  $config_dir = $facts['dcos_config_path']

  # make sure fact is defined
  if $facts['dcos_version'] and versioncmp($facts['dcos_version'], '1.13.0') < 0 {
    if !empty($metrics) {
      file { "${config_dir}/../etc/dcos-metrics-config.yaml":
        ensure  => 'file',
        content => template('dcos/dcos-metrics-config.erb'),
        notify  => Service['dcos-metrics-master'],
      }
    }

    service { 'dcos-metrics-master':
      ensure     => 'running',
      hasstatus  => true,
      hasrestart => true,
      enable     => true,
    }
  }

  service { $service_name:
    ensure     => 'running',
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => [File['/opt/mesosphere/etc/mesos-master-extras'],Anchor['dcos::master::installed']],
  }
}
