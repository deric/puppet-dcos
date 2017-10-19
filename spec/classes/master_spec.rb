require 'spec_helper'

describe 'dcos::master' do

  let(:facts) do
    {
      :operatingsystem => 'RedHat',
      :osfamily => 'RedHat',
      :puppetversion => Puppet.version,
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
      it { is_expected.to contain_package('tar').with_ensure('present') }
      it { is_expected.to contain_package('ipset').with_ensure('present') }
      it { is_expected.to contain_package('curl').with_ensure('present') }
      it { is_expected.to contain_package('xz').with_ensure('present') }
      it { is_expected.to contain_package('unzip').with_ensure('present') }
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
      }
    end

    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('dcos::master') }
    it { is_expected.to contain_class('dcos::install') }
    it { is_expected.to contain_class('dcos::config') }
    it { is_expected.to contain_class('dcos::os::debian') }

    it { is_expected.to contain_service('dcos-mesos-master') }

    context 'installed pre-requisities' do
      it { is_expected.to contain_package('ipset').with_ensure('present') }
      it { is_expected.to contain_package('curl').with_ensure('present') }
      it { is_expected.to contain_package('bc').with_ensure('present') }
      it { is_expected.to contain_package('selinux-utils').with_ensure('present') }
      it { is_expected.to contain_package('unzip').with_ensure('present') }
      it { is_expected.to contain_package('libcurl3-nss').with_ensure('present') }
      it { is_expected.to contain_package('tar').with_ensure('present') }
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
  end

end
