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
        Facter::Util::Resolution.exec(json['version'])
      end
    end
  end
end

Facter.add(:dcos_config_path) do
  setcode do
    adminrouter_file = '/opt/mesosphere/etc/adminrouter-listen-open.conf'
    if File.exists?(version_file)
      exec("dirname $(readlink -f /opt/mesosphere/etc/adminrouter-listen-open.conf)")
    end
  end
end