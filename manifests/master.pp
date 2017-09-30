# DC/OS master node
#
class dcos::master (
  $mesos = {},
  $manage_adminrouter = false,
  $service_name = 'dcos-mesos-master',
  $adminrouter = {}
) inherits ::dcos {

  if $manage_adminrouter {
    class{'dcos::adminrouter':
      config => $adminrouter,
    }
  }

  file {'/opt/mesosphere/etc/mesos-master-extras':
    ensure  => 'present',
    content => template('dcos/master-extras.erb'),
    notify  => Service[$service_name],
  }

  service { $service_name:
    ensure     => 'running',
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => File['/opt/mesosphere/etc/mesos-master-extras'],
  }

}
