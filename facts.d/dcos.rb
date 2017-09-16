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