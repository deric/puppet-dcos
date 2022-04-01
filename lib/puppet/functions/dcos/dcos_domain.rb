require 'json'
#
# @summary
#   Generates configuration for Mesos domains
#
#
Puppet::Functions.create_function(:'dcos::dcos_domain') do
  # @param arguments
  #   The original array of arguments. Port this to individually managed params
  #   to get the full benefit of the modern function API.
  #
  # @return [Data type]
  #   Describe what the function returns here
  #
  dispatch :default_impl do
    required_param 'String', :region
    required_param 'String', :zone
  end


  def default_impl(region, zone)
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
