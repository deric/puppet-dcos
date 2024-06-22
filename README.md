## puppet-dcos

[![Puppet
Forge](http://img.shields.io/puppetforge/v/deric/dcos.svg)](https://forge.puppetlabs.com/deric/dcos) [![Test](https://github.com/deric/puppet-dcos/actions/workflows/test.yml/badge.svg)](https://github.com/deric/puppet-dcos/actions/workflows/test.yml) [![Puppet Forge
Downloads](http://img.shields.io/puppetforge/dt/deric/dcos.svg)](https://forge.puppetlabs.com/deric/dcos/scores)

DC/OS nodes management

## Features

 * installation from bootstrap server
 * manage agent's attributes
 * provide `dcos-version` command (and export `dcos_version` fact e.g. to PuppetDB)
 * support running DC/OS on Debian based systems

## Installation from bootstrap server

When bootstrap URL is given, Puppet will try to install DC/OS (in case that there's no previous installation in `/opt/mesosphere`):
```yaml
dcos::bootstrap_url: 'http://192.168.1.1:9090'
# checksum of dcos_install.sh
dcos::install_checksum:
  type: 'sha1'
  hash: '43d6a53813bd9c68e26d0b3b8d8338182017dbb8'
```
then simply include DC/OS into node's definition. For master node:
```puppet
include dcos::master
```
For agent:
```puppet
include dcos::agent
```

Puppet will fetch `$bootstrap_script` (defaults to `dcos_install.sh`) and attempt to run [Advanced installation](https://dcos.io/docs/1.10/installing/custom/advanced/) e.g. `bash dcos_install.sh slave`.

Role `slave_public` can be also configured in Hiera backend:
```yaml
dcos::agent::public: true
```

You can also provide checksums for installation script:
```puppet

class {'dcos':
  bootstrap_url => 'http://192.168.1.1:9090',
  install_checksum => {
    type => 'sha1',
    hash => '43d6a53813bd9c68e26d0b3b8d8338182017dbb8'
  },
}
```

## Usage

Private DC/OS agent:

```puppet
class{'dcos::agent': }
```
Public agent:
```puppet
class{'dcos::agent':
  public => true
}
```

Agent accepts `mesos` hash with `ENV` variables that will override defaults in `/opt/mesosphere/etc/mesos-slave-common`.

Disabling CFS on agent node:
```puppet
class{'dcos::agent':
  mesos => {
    'MESOS_CGROUPS_ENABLE_CFS' => false
  }
}
```

Master node:

```puppet
class{'dcos::master':
  mesos => {
    'MESOS_QUORUM' => 2,
    'MESOS_max_completed_frameworks' => 50,
    'MESOS_max_completed_tasks_per_framework' => 1000,
    'MESOS_max_unreachable_tasks_per_framework' => 1000,
  }
}
```
`mesos` hash will create a file `/opt/mesosphere/etc/mesos-master-extras` overriding default `ENV` variables.

attributes:
```yaml
dcos::agent::attributes:
  dc: us-east
  storage: SATA
```

also existing facts can be easily used:
```yaml
dcos::agent::attributes:
  arch: "%{::architecture}"
  hostname: "%{::fqdn}"
```

## Mesos Resources

Resources offered by Mesos could be limited using [`MESOS_RESOURCES` ENV variable](https://mesos.readthedocs.io/en/latest/attributes-resources/).

Resources attribute:
```yaml
dcos::agent::resources:
  cpus:
    type: SCALAR
    scalar:
      value: 7.0
```
will be converted to JSON string that will be passed to `mesos-agent`
```json
[
  {
    "name": "cpus",
    "type": "SCALAR",
    "scalar": {
      "value": 7.0
    }
  }
]
```
NOTE: DC/OS merges `MESOS_RESOURCES` with allocated disk resources.

## YAML (Hiera/lookup) configuration

Simply use supported parameters:
```yaml
dcos::agent::mesos:
  MESOS_CGROUPS_ENABLE_CFS: false
dcos::master::mesos:
  MESOS_QUORUM: 2
```

## Limitations

Currently doesn't manage Docker dependency at all. Make sure appropriate Docker version is running before installing DC/OS.
