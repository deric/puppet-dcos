#!/bin/ruby
require 'facter'
require 'json'
# Retrieves DC/OS version, if installed
Facter.add(:dcos_version) do
  setcode do
    version_file = '/opt/mesosphere/etc/dcos-version.json'
    if File.exist?(version_file)
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
    if File.exist?(adminrouter_file)
      Facter::Util::Resolution.exec("dirname $(readlink -f #{adminrouter_file})")
    end
  end
end

Facter.add(:dcos_adminrouter_path) do
  setcode do
    dcos_env = '/opt/mesosphere/environment'
    if File.exist?(dcos_env)
      package_path = Facter::Util::Resolution.exec("cat /opt/mesosphere/environment | grep adminrouter | awk '{ print $3 }'")
      "/opt/mesosphere/packages/#{package_path}"
    end
  end
end

Facter.add(:dcos_include_master_conf) do
  setcode do
    master_conf = "#{Facter.value(:dcos_adminrouter_path)}/nginx/conf/includes/main/master.conf"
    File.exist?(master_conf)
  end
end
