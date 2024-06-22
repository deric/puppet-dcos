# == Class dcos::os::redhat
#
# DC/OS prerequisites (same for all node types)

class dcos::os::redhat {
  stdlib::ensure_packages(['tar','xz','unzip','curl','ipset','bc','ipvsadm'])
}
