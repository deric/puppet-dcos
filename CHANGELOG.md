## [2024-06-22] Release 1.0.0

* Use namespaced Puppet 4.x functions
* Require stdlib >= 9
* Replaced Anchors

* [full changes](https://github.com/deric/puppet-dcos/compare/v0.6.0...v1.0.0)


## [2020-12-08] Release 0.5.0

 * Don't replace existing files/symlinks on Debian (buster support)
 * adminrouterr config for 1.13
 * use ensure file in order to make sure that content is applied
 * allow common configuration for both master and agent

 * [full changes](https://github.com/deric/puppet-dcos/compare/v0.4.3...v0.5.0)


## [2018-08-20] Release 0.4.3
 * install DC/OS only into a non-empty directory (#1)

 * [full changes](https://github.com/deric/puppet-dcos/compare/v0.4.2...v0.4.3)

## [2017-12-22] Release 0.4.2
 * remove kmod dependency (modules should be loaded by navstar)
 * restart Mesos slave upon config changes

 * [full changes](https://github.com/deric/puppet-dcos/compare/v0.4.0...v0.4.2)

## [2017-12-21] Release 0.4.0
 * update `LD_LIBRARY_PATH` on Debian
 * load necessary kernel modules for Navstar (formerly Minuteman in DC/OS 1.9)
 * install admin tool `ipvsadm` for VLANs (useful for debugging)

 * [full changes](https://github.com/deric/puppet-dcos/compare/v0.3.1...v0.4.0)

## [2017-09-27] Release 0.3.1
 * [full changes](https://github.com/deric/puppet-dcos/compare/v0.3.0...v0.3.1)

### Bugfix
 * fix incorrect anchor

## [2017-09-27] Release 0.3.0
 * [full changes](https://github.com/deric/puppet-dcos/compare/v0.2.1...v0.3.0)

### Features
 * support installation from bootstrap server
 * experimental: provide SSL certificate for adminrouter

### Bugfix
 * fixed `ipset` symlink on Debian
 * fixed resolving DC/OS in Puppet fact

## [2017-09-27] Release 0.2.1
 * [full changes](https://github.com/deric/puppet-dcos/compare/v0.2.0...v0.2.1)
 * renamed `config` hash to `mesos` (for both master and agent)

## [2017-09-27] Release 0.2.0

 * [full changes](https://github.com/deric/puppet-dcos/compare/v0.1.0...v0.2.0)
 * support master nodes
 * version fact
 * allow modifing mesos-master and mesos-slave properties

## [2017-08-25] Release 0.1.0

 * initial release
 * supports public and private agents
