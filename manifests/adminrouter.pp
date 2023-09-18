# Adminrouter (nginx) config
#
# Config is a hash containing configuration:
#
#  dcos::master::adminrouter:
#    server_name: 'master.example.com'
#    ssl_certificate: '/etc/letsencrypt/live/master.example.com/fullchain.pem'
#    ssl_certificate_key: '/etc/letsencrypt/live/master.example.com/privkey.pem'
#
class dcos::adminrouter (
  Hash $config,
) {
  $server_name = pick($config['server_name'], 'master.mesos')
  $ssl_certificate = pick($config['ssl_certificate'], 'includes/snakeoil.crt')
  $ssl_certificate_key = pick($config['ssl_certificate_key'], 'includes/snakeoil.key')

  if 'default_scheme' in $config {
    $default_scheme = $config['default_scheme']
  }

  $config_dir = $::dcos_config_path
  $adminrouter_path = $::dcos_adminrouter_path
  $include_master_conf = $::dcos_include_master_conf

  if $config_dir and $adminrouter_path {
    file {"${config_dir}/adminrouter-listen-open.conf":
      ensure  => 'present',
      content => template('dcos/adminrouter-listen-open.conf.erb'),
      notify  => Service['dcos-adminrouter'],
    }

    file {"${adminrouter_path}/nginx/conf/nginx.master.conf":
      ensure => 'present',
      notify => Service['dcos-adminrouter'],
    }

    if versioncmp($::dcos_version, '1.13.0') >= 0 {
      File<| title == "${adminrouter_path}/nginx/conf/nginx.master.conf" |> {
        content => template('dcos/nginx.master.conf-1.13.erb'),
      }
    } else {
      File<| title == "${adminrouter_path}/nginx/conf/nginx.master.conf" |> {
        content => template('dcos/nginx.master.conf.erb'),
      }
    }

    file {"${config_dir}/../etc/adminrouter.env":
      ensure  => 'present',
      content => template('dcos/adminrouter.env.erb'),
      notify  => Service['dcos-adminrouter'],
    }

    service { 'dcos-adminrouter':
      ensure     => 'running',
      hasstatus  => true,
      hasrestart => true,
      enable     => true,
      require    => [
        File["${config_dir}/adminrouter-listen-open.conf"],
        File["${adminrouter_path}/nginx/conf/nginx.master.conf"]
      ],
    }
  }

}
