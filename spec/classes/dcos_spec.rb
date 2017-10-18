require 'spec_helper'

describe 'dcos' do

  context 'unsupported operating system' do
    describe 'dcos class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end

      it { expect { is_expected.to contain_package('dcos') }.to raise_error(Puppet::Error, /Solaris not supported/) }
    end
  end
end
