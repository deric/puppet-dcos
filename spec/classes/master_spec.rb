require 'spec_helper'

describe 'dcos::master' do

  let(:facts) do
    {
      :operatingsystem => 'RedHat',
      :osfamily => 'RedHat',
      :puppetversion => Puppet.version,
      :dcos_config_path => '/opt/mesosphere/packages/dcos-config--setup_8ec0bf2dda2a9d6b9426d63401297492434bfa46/etc_master',
      :dcos_version => '1.12.4',
    }
  end

  context 'on RedHat based systems' do
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('dcos::master') }
    it { is_expected.to contain_class('dcos::install') }
    it { is_expected.to contain_class('dcos::config') }
    it { is_expected.to contain_class('dcos::os::redhat') }

    it { is_expected.to contain_service('dcos-mesos-master') }

    context 'installed pre-requisities' do
      it { is_expected.to contain_package('tar').with_ensure(/present|installed/) }
      it { is_expected.to contain_package('ipset').with_ensure(/present|installed/) }
      it { is_expected.to contain_package('curl').with_ensure(/present|installed/) }
      it { is_expected.to contain_package('xz').with_ensure(/present|installed/) }
      it { is_expected.to contain_package('unzip').with_ensure(/present|installed/) }
    end
  end

  context 'on Debian based systems' do
    let(:facts) do
      {
        :operatingsystem => 'Debian',
        :osfamily => 'Debian',
        :lsbdistcodename => 'stretch',
        :lsbdistid => 'Debian',
        :puppetversion => Puppet.version,
        :dcos_config_path => '/opt/mesosphere/packages/dcos-config--setup_8ec0bf2dda2a9d6b9426d63401297492434bfa46/etc_master',
        :dcos_version => '1.12.4',
      }
    end

    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('dcos::master') }
    it { is_expected.to contain_class('dcos::install') }
    it { is_expected.to contain_class('dcos::config') }
    it { is_expected.to contain_class('dcos::os::debian') }

    it { is_expected.to contain_service('dcos-mesos-master').with_ensure('running') }
    it { is_expected.to contain_service('dcos-metrics-master').with_ensure('running') }

    context 'installed pre-requisities' do
      it { is_expected.to contain_package('ipset').with_ensure(/present|installed/) }
      it { is_expected.to contain_package('curl').with_ensure(/present|installed/) }
      it { is_expected.to contain_package('bc').with_ensure(/present|installed/) }
      it { is_expected.to contain_package('selinux-utils').with_ensure(/present|installed/) }
      it { is_expected.to contain_package('unzip').with_ensure(/present|installed/) }
      it { is_expected.to contain_package('libcurl3-nss').with_ensure(/present|installed/) }
      it { is_expected.to contain_package('tar').with_ensure(/present|installed/) }
    end

    context 'symlinks created' do
      it do
        is_expected.to contain_file('/usr/bin/bash').with({
          'ensure' => 'link',
          'target' => '/bin/bash',
        })
      end

      it do
        is_expected.to contain_file('/usr/bin/rm').with({
          'ensure' => 'link',
          'target' => '/bin/rm',
        })
      end

      it do
        is_expected.to contain_file('/usr/bin/tar').with({
          'ensure' => 'link',
          'target' => '/bin/tar',
        })
      end

      it do
        is_expected.to contain_file('/usr/bin/mkdir').with({
          'ensure' => 'link',
          'target' => '/bin/mkdir',
        })
      end

      it do
        is_expected.to contain_file('/usr/bin/ln').with({
          'ensure' => 'link',
          'target' => '/bin/ln',
        })
      end

      it do
        is_expected.to contain_file('/sbin/useradd').with({
          'ensure' => 'link',
          'target' => '/usr/sbin/useradd',
        })
      end

      it do
        is_expected.to contain_file('/usr/sbin/ipset').with({
          'ensure' => 'link',
          'target' => '/sbin/ipset',
        })
      end
    end

  end

  context 'dc/os 1.13' do
    let(:facts) do
      {
        :operatingsystem => 'Debian',
        :osfamily => 'Debian',
        :lsbdistcodename => 'stretch',
        :lsbdistid => 'Debian',
        :puppetversion => Puppet.version,
        :dcos_config_path => '/opt/mesosphere/packages/dcos-config--setup_8ec0bf2dda2a9d6b9426d63401297492434bfa46/etc_master',
        :dcos_version => '1.13.2',
      }
    end

    it { is_expected.not_to contain_service('dcos-metrics-master').with_ensure('running') }
  end

  context 'CFS' do
    let :pre_condition do
      'class {"dcos::master":
         mesos => {
           "MESOS_max_completed_frameworks" => 50
         }
       }'
    end

    it do
      is_expected.to contain_file(
        '/opt/mesosphere/etc/mesos-master-extras'
      ).with_content(/MESOS_MAX_COMPLETED_FRAMEWORKS=50/)
    end
  end

  context 'adminrouter' do
    let(:facts) do
      {
        :operatingsystem => 'Debian',
        :osfamily => 'Debian',
        :lsbdistcodename => 'stretch',
        :lsbdistid => 'Debian',
        :puppetversion => Puppet.version,
        :dcos_config_path => '/opt/mesosphere/packages/dcos-config--setup_8ec0bf2dda2a9d6b9426d63401297492434bfa46/etc_master',
        :dcos_adminrouter_path => '/opt/mesosphere/packages/adminrouter--e0de512c046bee17e0d458d10e7c8c2b24f56fc6',
        :dcos_include_master_conf => false,
        :dcos_version => '1.11.9',
      }
    end
    let :pre_condition do
      'class {"dcos::master":
         manage_adminrouter => true,
         adminrouter => {
           server_name => "foo.bar",
           ssl_certificate => "/etc/ssl/cert.crt",
           service_name => "mesos.test",
           ssl_certificate_key => "/etc/ssl/cert.key",
         },
       }'
    end

    it do
      is_expected.to contain_file(
        '/opt/mesosphere/packages/dcos-config--setup_8ec0bf2dda2a9d6b9426d63401297492434bfa46/etc_master/adminrouter-listen-open.conf'
      ).with_content(/^ssl_certificate \/etc\/ssl\/cert.crt;/)
    end

    it do
      is_expected.to contain_file(
        '/opt/mesosphere/packages/dcos-config--setup_8ec0bf2dda2a9d6b9426d63401297492434bfa46/etc_master/adminrouter-listen-open.conf'
      ).with_content(/^ssl_certificate_key \/etc\/ssl\/cert.key;/)
    end

    it do
      is_expected.to contain_file(
        '/opt/mesosphere/packages/adminrouter--e0de512c046bee17e0d458d10e7c8c2b24f56fc6/nginx/conf/nginx.master.conf'
      ).with_content(/server_name foo.bar;/)
    end

    it do
      is_expected.not_to contain_file(
        '/opt/mesosphere/packages/dcos-config--setup_8ec0bf2dda2a9d6b9426d63401297492434bfa46/etc_master/../etc/adminrouter.env'
      ).with_content(/DEFAULT_SCHEME/)
    end

    context 'force https' do
      let :pre_condition do
        'class {"dcos::master":
           manage_adminrouter => true,
           adminrouter => {
             server_name => "foo.bar",
             ssl_certificate => "/etc/ssl/cert.crt",
             service_name => "mesos.test",
             ssl_certificate_key => "/etc/ssl/cert.key",
             default_scheme => "https://",
           },
         }'
      end

        it do
          is_expected.to contain_file(
            '/opt/mesosphere/packages/dcos-config--setup_8ec0bf2dda2a9d6b9426d63401297492434bfa46/etc_master/../etc/adminrouter.env'
          ).with_content(/DEFAULT_SCHEME=https:\/\//)
        end
    end
  end

  context 'adminrouter 1.13' do
    let(:facts) do
      {
        :operatingsystem => 'Debian',
        :osfamily => 'Debian',
        :lsbdistcodename => 'stretch',
        :lsbdistid => 'Debian',
        :puppetversion => Puppet.version,
        :dcos_config_path => '/opt/mesosphere/packages/dcos-config--setup_8ec0bf2dda2a9d6b9426d63401297492434bfa46/etc_master',
        :dcos_adminrouter_path => '/opt/mesosphere/packages/adminrouter--e0de512c046bee17e0d458d10e7c8c2b24f56fc6',
        :dcos_include_master_conf => false,
        :dcos_version => '1.13.2',
      }
    end
    let :pre_condition do
      'class {"dcos::master":
         manage_adminrouter => true,
         adminrouter => {
           server_name => "foo.bar",
           ssl_certificate => "/etc/ssl/cert.crt",
           service_name => "mesos.test",
           ssl_certificate_key => "/etc/ssl/cert.key",
         },
       }'
    end

    it do
      is_expected.to contain_file(
        '/opt/mesosphere/packages/adminrouter--e0de512c046bee17e0d458d10e7c8c2b24f56fc6/nginx/conf/nginx.master.conf'
      ).with_content(/server_name foo.bar;/)
    end

  end

  context 'installation from bootstrap url' do
    let :pre_condition do
      'class {"dcos":
        bootstrap_url => "http://192.168.1.1:9090",
        install_checksum => {
          type => "sha1",
          hash => "43d6a53813bd9c68e26d0b3b8d8338182017dbb8"
        },
      }
      class {"dcos::master": }'
    end

    it do
      is_expected.to contain_archive(
        "/tmp/dcos/dcos_install.sh"
      ).with({
        'source' => 'http://192.168.1.1:9090/dcos_install.sh',
      })
    end

    it do
      is_expected.to contain_anchor('dcos::install::begin')
    end

    it do
      is_expected.to contain_exec('dcos master install')
        .that_comes_before('Anchor[dcos::master::installed]')
    end

    it do
      is_expected.to contain_exec('dcos master install').with({
        'command' => 'bash /tmp/dcos/dcos_install.sh master'
      })
    end

  end

  context 'metrics config' do
    let(:facts) do
      {
        :operatingsystem => 'Debian',
        :osfamily => 'Debian',
        :lsbdistcodename => 'stretch',
        :lsbdistid => 'Debian',
        :puppetversion => Puppet.version,
        :dcos_config_path => '/opt/mesosphere/packages/dcos-config--setup_8ec0bf2dda/etc_master',
        :dcos_version => '1.11.9',
      }
    end
    let :pre_condition do
      'class {"dcos::master":
         metrics => {
           "producers" => {
              "prometheus" => {
                "port" => 61091
              }
           }
         }
       }'
    end

    it do
      is_expected.to contain_file(
        '/opt/mesosphere/packages/dcos-config--setup_8ec0bf2dda/etc_master/../etc/dcos-metrics-config.yaml'
      ).with_content(/port: 61091/)
    end
  end

  context 'domain' do
    let(:facts) do
      {
        :operatingsystem => 'Debian',
        :osfamily => 'Debian',
        :lsbdistcodename => 'stretch',
        :lsbdistid => 'Debian',
        :puppetversion => Puppet.version,
        :dcos_config_path => '/opt/mesosphere/packages/dcos-config--setup_8ec0bf2dda/etc_master',
        :dcos_version => '1.11.9',
      }
    end
    let :pre_condition do
      'class {"dcos::master":
         region => "us-east",
       }'
    end

    it do
      is_expected.to contain_file(
        '/var/lib/dcos/mesos-master-domain.json'
      ).with_content(/"name":"us-east"/)
    end
  end

end
