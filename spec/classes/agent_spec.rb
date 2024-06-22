require 'spec_helper'

describe 'dcos::agent' do
  let(:facts) do
    {
      os: {
        family: 'RedHat'
      },
      operatingsystem: 'RedHat',
      osfamily: 'RedHat',
      puppetversion: Puppet.version,
      dcos_config_path: '/opt/mesosphere/packages/dcos-config--setup_8ec0bf2dda2a9d6b9426d63401297492434bfa46/etc_master',
    }
  end

  context 'on RedHat based systems' do
    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('dcos::agent') }
    it { is_expected.to contain_class('dcos::install') }
    it { is_expected.to contain_class('dcos::config') }
    it { is_expected.to contain_class('dcos::os::redhat') }

    it { is_expected.to contain_service('dcos-mesos-slave') }

    context 'installed pre-requisities' do
      it { is_expected.to contain_package('tar').with_ensure(%r{present|installed}) }
      it { is_expected.to contain_package('ipset').with_ensure(%r{present|installed}) }
      it { is_expected.to contain_package('curl').with_ensure(%r{present|installed}) }
      it { is_expected.to contain_package('xz').with_ensure(%r{present|installed}) }
      it { is_expected.to contain_package('unzip').with_ensure(%r{present|installed}) }
    end
  end

  context 'on Debian based systems' do
    let(:facts) do
      {
        os: {
          family: 'Debian'
        },
        operatingsystem: 'Debian',
        osfamily: 'Debian',
        lsbdistcodename: 'stretch',
        lsbdistid: 'Debian',
        puppetversion: Puppet.version,
        dcos_config_path: '/opt/mesosphere/packages/dcos-config--setup_8ec0bf2dda2a9d6b9426d63401297492434bfa46/etc_master',
      }
    end

    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_class('dcos::agent') }
    it { is_expected.to contain_class('dcos::install') }
    it { is_expected.to contain_class('dcos::config') }
    it { is_expected.to contain_class('dcos::os::debian') }

    it { is_expected.to contain_service('dcos-mesos-slave') }

    context 'installed pre-requisities' do
      it { is_expected.to contain_package('ipset').with_ensure(%r{present|installed}) }
      it { is_expected.to contain_package('curl').with_ensure(%r{present|installed}) }
      it { is_expected.to contain_package('bc').with_ensure(%r{present|installed}) }
      it { is_expected.to contain_package('selinux-utils').with_ensure(%r{present|installed}) }
      it { is_expected.to contain_package('unzip').with_ensure(%r{present|installed}) }
      it { is_expected.to contain_package('libcurl3-nss').with_ensure(%r{present|installed}) }
      it { is_expected.to contain_package('tar').with_ensure(%r{present|installed}) }
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

  context 'mesos executor' do
    let :pre_condition do
      'class {"dcos::agent":
        executor => {"foo" => "6"}
      }'
    end

    it do
      is_expected.to contain_file(
        '/opt/mesosphere/packages/dcos-config--setup_8ec0bf2dda2a9d6b9426d63401297492434bfa46/etc_master/../etc/mesos-executor-environment.json',
      ).with_content(%r{\{"foo":"6"\}})
    end
  end

  context 'CFS' do
    let :pre_condition do
      'class {"dcos::agent":
         mesos => {
           "MESOS_CGROUPS_ENABLE_CFS" => false
         }
       }'
    end

    it do
      is_expected.to contain_file(
        '/var/lib/dcos/mesos-slave-common',
      ).with_content(%r{MESOS_CGROUPS_ENABLE_CFS=false})
    end
  end

  context 'attributes' do
    let :pre_condition do
      'class {"dcos::agent":
         attributes => {
           "dc" => "us-east",
           "instance" => "large",
         }
       }'
    end

    it do
      is_expected.to contain_file(
        '/var/lib/dcos/mesos-slave-common',
      ).with_content(%r{MESOS_ATTRIBUTES="dc:us-east;instance:large;"})
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
      class {"dcos::agent": }'
    end

    it do
      is_expected.to contain_archive(
        '/tmp/dcos/dcos_install.sh',
      ).with({
               'source' => 'http://192.168.1.1:9090/dcos_install.sh',
             })
    end

    it do
      is_expected.to contain_file('/tmp/dcos').with_ensure('directory')
    end

    it do
      is_expected.to contain_exec('dcos slave install').with({
                                                               'command' => 'bash /tmp/dcos/dcos_install.sh slave',
                                                             })
    end

    it do
      is_expected.to contain_exec('dcos slave install')
        .that_comes_before('Service[dcos-mesos-slave]')
    end
  end

  context 'domain' do
    let :pre_condition do
      'class {"dcos::agent":
         region => "us-east",
       }'
    end

    it do
      is_expected.to contain_file(
        '/var/lib/dcos/mesos-agent-domain.json',
      ).with_content(%r{"name":"us-east"})
    end
  end

  context 'resources' do
    let :pre_condition do
      'class {"dcos::agent":
         resources => {
           "cpus" => {
              "type" => "SCALAR",
              "scalar" => {
                "value" => 6.0
              }
           }
         }
       }'
    end

    it do
      is_expected.to contain_file(
        '/var/lib/dcos/mesos-slave-common',
      ).with_content(
        %r{MESOS_RESOURCES=\"\[\{\\\"type\\\":\\\"SCALAR\\\",\\\"scalar\\\":\{\\\"value\\\":6.0\},\\\"name\\\":\\\"cpus\\\"\}\]\"},
      )
    end
  end

  context 'do not manage service' do
    let(:params) do
      {
        manage_service: false,
     public: false,
      }
    end

    it { is_expected.not_to contain_service('dcos-mesos-slave') }
  end

  context 'do not manage service on public node' do
    let(:params) do
      {
        manage_service: false,
     public: true,
      }
    end

    it { is_expected.not_to contain_service('dcos-mesos-slave-public') }
  end
end
