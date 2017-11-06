# DC/OS master node
#
class dcos::master (
  $mesos = {},
  $manage_adminrouter = false,
  $service_name = 'dcos-mesos-master',
  $adminrouter = {}
) inherits ::dcos {

  anchor { 'dcos::master::installed': }

  if $::dcos::bootstrap_url {
    exec { 'dcos master install':
      command     => "bash ${::dcos::download_dir}/dcos_install.sh master",
      path        => '/bin:/usr/bin:/usr/sbin',
      onlyif      => 'test ! -d /opt/mesosphere',
      refreshonly => false,
      before      => Anchor['dcos::master::installed'],
    }
  }

  case $::osfamily {
    'Debian': {
      # make sure to try system library first
      file_line { 'update LD_PATH /opt/mesosphere/environment':
        path => '/opt/mesosphere/environment',
        line => 'LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/opt/mesosphere/lib',
        match   => '^LD_LIBRARY_PATH=*',
        replace => true,
        require => Anchor['dcos::master::installed'],
      }
    }
  }

  if $manage_adminrouter {
    class{'::dcos::adminrouter':
      config  => $adminrouter,
      require => Anchor['dcos::master::installed'],
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
    require    => [File['/opt/mesosphere/etc/mesos-master-extras'],Anchor['dcos::master::installed']],
  }

}
