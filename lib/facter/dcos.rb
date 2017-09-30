#!/bin/ruby
require 'facter'
require 'json'
# Retrieves DC/OS version, if installed
Facter.add(:dcos_version) do
  setcode do
    version_file = '/opt/mesosphere/etc/dcos-version.json'
    if File.exists?(version_file)
      json = JSON.parse(File.read(version_file))
      if json.key? 'version'
        json['version']
      end
    end
  end
end

Facter.add(:dcos_config_path) do
  setcode do
    adminrouter_file = '/opt/mesosphere/etc/adminrouter-listen-open.conf'
    if File.exists?(adminrouter_file)
      Facter::Util::Resolution.exec("dirname $(readlink -f #{adminrouter_file})")
    end
  end
end

Facter.add(:dcos_adminrouter_path) do
  setcode do
    adminrouter_service = '/etc/systemd/system/dcos-adminrouter.service'
    if File.exists?(adminrouter_service)
      service_path = Facter::Util::Resolution.exec("dirname $(readlink -f #{adminrouter_service})")
      File.expand_path('..', service_path)
    end
  end
end