#! /usr/bin/env ruby -S rspec
# frozen_string_literal: true

require 'spec_helper'
require 'rspec-puppet'

describe 'dcos::domain' do
  describe 'basic usage ' do
    it 'should raise an error if run with extra arguments' do
      is_expected.to run.with_params(1, 2, 3, 4).and_raise_error(ArgumentError)
    end

    it 'should raise an error when running without arguments' do
      is_expected.to run.with_params(nil).and_raise_error(ArgumentError)
    end
  end

  describe 'generate config' do
    it 'when zone and region is defined' do
      is_expected.to run.with_params('us-east', 'us-east-aws').and_return(
        "{\"fault_domain\":{\"region\":{\"name\":\"us-east\"},\"zone\":{\"name\":\"us-east-aws\"}}}"
      )
    end

  end

end
