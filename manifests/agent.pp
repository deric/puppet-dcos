class dcos::agent (
  $public = false,
  $attributes = {},
) inherits ::dcos {

  if $public {
    $dcos_mesos_service = 'dcos-mesos-slave-public'
  } else {
    $dcos_mesos_service = 'dcos-mesos-slave'
  }

  file {'/var/lib/dcos/mesos-slave-common':
    ensure => 'present',
    content => template('dcos/agent-common.erb'),
  }

  exec {'stop-dcos-agent':
    command     => "systemctl kill -s SIGUSR1 ${dcos_mesos_service} && systemctl stop ${dcos_mesos_service}",
    path        => '/bin:/usr/bin:/usr/sbin',
    refreshonly => true,
    subscribe   => File['/var/lib/dcos/mesos-slave-common'],
    notify      => Exec['dcos-systemd-reload'],
  }

  exec { 'dcos-systemd-reload':
    command     => 'systemctl daemon-reload && rm -f /var/lib/mesos/slave/meta/slaves/latest',
    path        => '/bin:/usr/bin:/usr/sbin',
    refreshonly => true,
  }

  service { $dcos_mesos_service:
    ensure     => 'running',
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }
}
