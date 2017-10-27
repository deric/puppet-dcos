# DC/OS agent node
#
class dcos::agent (
  $public = false,
  $attributes = {},
  $mesos = {},
  $executor = $::dcos::params::executor,
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
      onlyif      => 'test ! -d /opt/mesosphere',
      refreshonly => false,
      before      => Anchor['dcos::agent::installed'],
    }
  }

  $config_dir = $::dcos_config_path

  file {"${config_dir}/../etc/mesos-executor-environment.json":
    ensure  => 'present',
    content => dcos_sorted_json($executor),
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
    ensure  => 'present',
    content => template('dcos/agent-common.erb'),
    require => File['/var/lib/dcos'],
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
