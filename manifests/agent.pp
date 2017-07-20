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
    notify  => Exec['stop-dcos-agent'],
  }

  exec {'stop-dcos-agent':
    command => "systemctl kill -s SIGUSR1 ${dcos_mesos_service} && systemctl stop ${dcos_mesos_service}",
    path    => '/bin:/usr/bin:/usr/sbin',
    notify  => Exec['dcos-systemd-reload'],
  }

  exec { 'dcos-systemd-reload':
    command     => 'systemctl daemon-reload',
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
