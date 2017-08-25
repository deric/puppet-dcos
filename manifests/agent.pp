class dcos::agent (
  $public = false,
  $attributes = {},
) inherits ::dcos {

  if $public {
    $dcos_mesos_service = 'dcos-mesos-slave-public'
  } else {
    $dcos_mesos_service = 'dcos-mesos-slave'
  }

  file {'/var/lib/dcos':
    ensure => 'directory',
  }

  file_line {'default_tasks_max':
    line      => 'DefaultTasksMax=infinity',
    path      => '/etc/systemd/system.conf',
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
    onlyif      => "test -d /var/lib/dcos",
    subscribe   => File['/var/lib/dcos/mesos-slave-common'],
    notify      => Exec['dcos-systemd-reload'],
  }

  exec { 'dcos-systemd-reload':
    command     => 'systemctl daemon-reload && rm -f /var/lib/mesos/slave/meta/slaves/latest',
    path        => '/bin:/usr/bin:/usr/sbin',
    onlyif      => "test -d /var/lib/dcos",
    refreshonly => true,
  }

  service { $dcos_mesos_service:
    ensure     => 'running',
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }
}
