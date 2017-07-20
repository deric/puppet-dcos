class dcos::agent (
  $public = false,
) inherits ::dcos {


  if $public {
    $dcos_mesos_service = 'dcos-mesos-slave'
  } else {
    $dcos_mesos_service = 'dcos-mesos-slave-public'
  }

  service { $dcos_mesos_service:
    ensure     => 'running',
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }
}
