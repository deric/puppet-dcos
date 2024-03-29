#! /usr/bin/env ruby -S rspec
# frozen_string_literal: true

require 'spec_helper'
require 'rspec-puppet'
require 'json'

describe 'dcos::resources' do
  describe 'basic usage ' do
    it 'raises an error if run with extra arguments' do
      is_expected.to run.with_params(1, 2).and_raise_error(ArgumentError)
    end

    it 'raises an error when running without arguments' do
      is_expected.to run.with_params(nil).and_raise_error(NoMethodError)
    end
  end

  describe 'generate config' do
    it 'when zone and region is defined' do
      resources = {
        "cpus": {
          "type": 'SCALAR',
          "scalar": {
            "value": 7.0
          }
        }
      }

      mesos_res = [
        {
          "type": 'SCALAR',
          "scalar": {
            "value": 7.0
          },
          "name": 'cpus'
        },
      ]
      is_expected.to run.with_params(resources).and_return(
        mesos_res.to_json,
      )
    end
  end
end
