# @summary Executes bootstrap
# @param role installed role
class dcos::bootstrap (
  String $role,
) {
  if $dcos::bootstrap_url {
    exec { "dcos ${role} install":
      command     => "bash ${dcos::download_dir}/dcos_install.sh ${role}",
      path        => '/bin:/usr/bin:/usr/sbin',
      onlyif      => 'test -z "`ls -A /opt/mesosphere`"',
      refreshonly => false,
    }
  }
}
