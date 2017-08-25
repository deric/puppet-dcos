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
  end

end
