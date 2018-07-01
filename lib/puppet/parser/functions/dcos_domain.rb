require 'json'

module Puppet::Parser::Functions
  newfunction(:dcos_domain, :type => :rvalue, :doc => <<-EOS
Generates configuration for Mesos domains
    EOS
  ) do |arguments|

    raise(Puppet::ParseError, "sorted_json(): Wrong number of arguments " +
      "given (#{arguments.size} for 2)") if arguments.size != 2

    region = arguments[0]
    zone = arguments[1]
    conf = {"fault_domain" => {}}

    if region
      conf["fault_domain"]["region"] = {"name" => region}
    end

    if zone
      conf["fault_domain"]["zone"] = {"name" => zone}
    end
    return conf.to_json
  end
end
