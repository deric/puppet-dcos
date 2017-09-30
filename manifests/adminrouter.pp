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
  $config,
) {
  $server_name = pick($config['server_name'], 'master.mesos')
  $ssl_certificate = pick($config['ssl_certificate'], 'includes/snakeoil.crt')
  $ssl_certificate_key = pick($config['ssl_certificate_key'], 'includes/snakeoil.key')

  file {'/opt/mesosphere/etc/adminrouter-listen-open.conf':
    ensure  => 'present',
    content => template('dcos/adminrouter-listen-open.conf.erb'),
    notify  => Service['dcos-adminrouter'],
  }

  service { 'dcos-adminrouter':
    ensure     => 'running',
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => File['/opt/mesosphere/etc/adminrouter-listen-open.conf'],
  }

}