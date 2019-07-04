# DC/OS agent node
#
class dcos::agent (
  $public = false,
  $attributes = {},
  $mesos = {},
  $resources = {},
  $executor = $::dcos::params::executor,
  $region = $::dcos::region,
  $zone = $::dcos::zone,
) inherits ::dcos {

  anchor { 'dcos::agent::installed': }

  if $public {
    $dcos_mesos_service = 'dcos-mesos-slave-public'
    $role = 'slave_public'
  } else {
    $dcos_mesos_service = 'dcos-mesos-slave'
    $role = 'slave'
  }

  if $::dcos::bootstrap_url {
    exec { 'dcos agent install':
      command     => "bash ${::dcos::download_dir}/dcos_install.sh ${role}",
      path        => '/bin:/usr/bin:/usr/sbin',
      onlyif      => 'test -z "`ls -A /opt/mesosphere`"',
      refreshonly => false,
      before      => Anchor['dcos::agent::installed'],
    }
  }

  case $::osfamily {
    'Debian': {
      # needed for DC/OS < 1.11
      # make sure to try system library first
      file_line { 'update LD_PATH /opt/mesosphere/environment':
        path    => '/opt/mesosphere/environment',
        line    => 'LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/opt/mesosphere/lib',
        match   => '^LD_LIBRARY_PATH=*',
        replace => true,
        require => Anchor['dcos::agent::installed'],
      }
    }
    default: { }
  }

  $config_dir = $::dcos_config_path

  file {"${config_dir}/../etc/mesos-executor-environment.json":
    ensure  => 'file',
    content => dcos_sorted_json($executor),
    notify  => Service[$dcos_mesos_service],
    require => Anchor['dcos::agent::installed'],
  }

  file {'/var/lib/dcos':
    ensure => 'directory',
  }

  file_line {'default_tasks_max':
    line => 'DefaultTasksMax=infinity',
    path => '/etc/systemd/system.conf',
  }

  file {'/var/lib/dcos/mesos-slave-common':
    ensure  => 'file',
    content => template('dcos/agent-common.erb'),
    notify  => Service[$dcos_mesos_service],
    require => File['/var/lib/dcos'],
  }

  if $region or $zone {
    file {'/var/lib/dcos/mesos-agent-domain.json':
      ensure  => 'file',
      content => dcos_domain($region, $zone),
      notify  => Service[$dcos_mesos_service],
      require => File['/var/lib/dcos'],
    }
  }

  exec {'stop-dcos-agent':
    command     => "systemctl kill -s SIGUSR1 ${dcos_mesos_service} && systemctl stop ${dcos_mesos_service}",
    path        => '/bin:/usr/bin:/usr/sbin',
    refreshonly => true,
    onlyif      => 'test -d /var/lib/dcos',
    subscribe   => File['/var/lib/dcos/mesos-slave-common'],
    notify      => Exec['dcos-systemd-reload'],
    require     => Anchor['dcos::agent::installed'],
  }

  exec { 'dcos-systemd-reload':
    command     => 'systemctl daemon-reload && rm -f /var/lib/mesos/slave/meta/slaves/latest',
    path        => '/bin:/usr/bin:/usr/sbin',
    onlyif      => 'test -d /var/lib/dcos',
    refreshonly => true,
    require     => Anchor['dcos::agent::installed'],
  }

  service { $dcos_mesos_service:
    ensure     => 'running',
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => Anchor['dcos::agent::installed'],
  }
}
