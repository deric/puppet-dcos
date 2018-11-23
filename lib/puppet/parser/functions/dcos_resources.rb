require 'json'

module Puppet::Parser::Functions
  newfunction(:dcos_resources, :type => :rvalue, :doc => <<-EOS
Convert resources hash to a JSON format accepted by Mesos
    EOS
  ) do |arguments|

    if arguments.size > 0 and arguments[0].nil?
      raise(Puppet::ParseError, "dcos_resources(): expected valid hash, got nil")
      return nil
    end

    raise(Puppet::ParseError, "dcos_resources(): Wrong number of arguments " +
      "given (#{arguments.size} instead of 1") if arguments.size != 1

    resources = arguments[0]
    mesos_res = []
    resources.each do |k, v|
      v["name"] = k
      mesos_res << v
    end

    return mesos_res.to_json
  end
end
