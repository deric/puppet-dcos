require 'json'
#
# @summary
#   Convert resources hash to a JSON format accepted by Mesos
#
#
Puppet::Functions.create_function(:'dcos::resources') do
  # @param arguments
  #   The original array of arguments. Port this to individually managed params
  #   to get the full benefit of the modern function API.
  #
  # @return [Data type]
  #   Describe what the function returns here
  #
  dispatch :default_impl do
    required_param 'Any', :resources
  end

  def default_impl(resources)
    mesos_res = []
    resources.each do |k, v|
      value = v.dup
      value['name'] = k
      mesos_res << value
    end

    mesos_res.to_json
  end
end
