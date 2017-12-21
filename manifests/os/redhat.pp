# == Class dcos::os::redhat
#
# DC/OS prerequisites (same for all node types)

class dcos::os::redhat {
  ensure_packages(['tar','xz','unzip','curl','ipset','bc','ipvsadm'])
}