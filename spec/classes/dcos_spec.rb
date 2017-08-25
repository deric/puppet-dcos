require 'spec_helper'

describe 'dcos' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "dcos class without any parameters" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('dcos::params') }
          it { is_expected.to contain_class('dcos::install').that_comes_before('dcos::config') }
          it { is_expected.to contain_class('dcos::config') }
          it { is_expected.to contain_class('dcos::service').that_subscribes_to('dcos::config') }

          it { is_expected.to contain_service('dcos') }
          it { is_expected.to contain_package('dcos').with_ensure('present') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'dcos class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end

      it { expect { is_expected.to contain_package('dcos') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
