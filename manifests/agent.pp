# DC/OS agent node
#
# @param public
# @param attributes
# @param mesos
# @param resources
# @param executor
# @param region
#    DC region
# @param zone
#    Availability zone
# @param manage_service
#    Whether service should be restarted upon config changes
# @param force_reload
#    Upon attribute changes agent will be unregistered
# @param modify_ldpath
#    Whether LD_PATH should be touched
#
class dcos::agent (
  Boolean          $public = false,
  Hash             $attributes = {},
  Hash             $mesos = {},
  Hash             $resources = {},
  Hash             $executor = $dcos::params::executor,
  Optional[String] $region = $dcos::region,
  Optional[String] $zone = $dcos::zone,
  Boolean          $manage_service = true,
  Boolean          $force_reload = true,
  Boolean          $modify_ldpath = true,
) inherits dcos {
  if $public {
    $dcos_mesos_service = 'dcos-mesos-slave-public'
    $role = 'slave_public'
  } else {
    $dcos_mesos_service = 'dcos-mesos-slave'
    $role = 'slave'
  }

  class { 'dcos::bootstrap':
    role    => $role,
    require => Class['Dcos::Install'],
  }

  $_manage_service = $manage_service ? {
    true    => Service[$dcos_mesos_service],
    default => [],
  }

  case $facts['os']['family'] {
    'Debian': {
      if $modify_ldpath {
        # needed for DC/OS < 1.11
        # make sure to try system library first
        file_line { 'update LD_PATH /opt/mesosphere/environment':
          path    => '/opt/mesosphere/environment',
          line    => 'LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/opt/mesosphere/lib',
          match   => '^LD_LIBRARY_PATH=*',
          replace => true,
          require => Class['Dcos::Bootstrap'],
        }
      }
    }
    default: {}
  }

  $config_dir = $facts['dcos_config_path']

  file { "${config_dir}/../etc/mesos-executor-environment.json":
    ensure  => 'file',
    content => dcos::sorted_json($executor),
    notify  => $_manage_service,
    require => Class['Dcos::Bootstrap'],
  }

  file { '/var/lib/dcos':
    ensure => 'directory',
  }

  file_line { 'default_tasks_max':
    line => 'DefaultTasksMax=infinity',
    path => '/etc/systemd/system.conf',
  }

  file { '/var/lib/dcos/mesos-slave-common':
    ensure  => 'file',
    content => template('dcos/agent-common.erb'),
    notify  => $_manage_service,
    require => File['/var/lib/dcos'],
  }

  if $region or $zone {
    file { '/var/lib/dcos/mesos-agent-domain.json':
      ensure  => 'file',
      content => dcos::domain($region, $zone),
      notify  => $_manage_service,
      require => File['/var/lib/dcos'],
    }
  }

  if $force_reload {
    exec { 'stop-dcos-agent':
      command     => "systemctl kill -s SIGUSR1 ${dcos_mesos_service} && systemctl stop ${dcos_mesos_service}",
      path        => '/bin:/usr/bin:/usr/sbin',
      refreshonly => true,
      onlyif      => 'test -d /var/lib/dcos',
      subscribe   => File['/var/lib/dcos/mesos-slave-common'],
      notify      => Exec['dcos-systemd-reload'],
      require     => Class['Dcos::Bootstrap'],
    }

    exec { 'dcos-systemd-reload':
      command     => 'systemctl daemon-reload && rm -f /var/lib/mesos/slave/meta/slaves/latest',
      path        => '/bin:/usr/bin:/usr/sbin',
      onlyif      => 'test -d /var/lib/dcos',
      refreshonly => true,
      require     => Class['Dcos::Bootstrap'],
    }
  }

  if $manage_service {
    service { $dcos_mesos_service:
      ensure     => 'running',
      hasstatus  => true,
      hasrestart => true,
      enable     => true,
      require    => Class['Dcos::Bootstrap'],
    }
  }
}
