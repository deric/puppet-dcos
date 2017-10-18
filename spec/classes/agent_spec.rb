require 'spec_helper'

describe 'dcos::agent' do

  let(:facts) do
    {
    :operatingsystem => 'Debian',
    :osfamily => 'Debian',
    :lsbdistcodename => 'stretch',
    :lsbdistid => 'Debian',
    :puppetversion => Puppet.version,
  }
  end


  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "dcos class without any parameters" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('dcos::agent') }
          it { is_expected.to contain_class('dcos::install') }
          it { is_expected.to contain_class('dcos::config') }

          it { is_expected.to contain_service('dcos-mesos-slave') }
        end
      end
    end
  end

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
        '/var/lib/dcos/mesos-slave-common'
      ).with_content(/MESOS_CGROUPS_ENABLE_CFS=false/)
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
        '/var/lib/dcos/mesos-slave-common'
      ).with_content(/MESOS_ATTRIBUTES=dc:us-east;instance:large;/)
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
        "/tmp/dcos/dcos_install.sh"
      ).with({
        'source' => 'http://192.168.1.1:9090/dcos_install.sh',
      })
    end

    it do
      is_expected.to contain_anchor('dcos::install::begin')
    end

  end

end
