require 'spec_helper'

describe 'dcos::dcos_sorted_json' do
  # without knowing details about the implementation, this is the only test
  # case that we can autogenerate. You should add more examples below!
  it { is_expected.not_to eq(nil) }

  it 'returns the proper output' do
    json = {'foo'=> 'value', 'bar' => 'value'}
    sorted = "{\"bar\":\"value\",\"foo\":\"value\"}"
    is_expected.to run.with_params(json).and_return(sorted)
  end

end
