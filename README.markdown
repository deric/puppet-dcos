## puppet-dcos

[![Puppet
Forge](http://img.shields.io/puppetforge/v/deric/dcos.svg)](https://forge.puppetlabs.com/deric/dcos) [![Build Status](https://travis-ci.org/deric/puppet-dcos.png?branch=master)](https://travis-ci.org/deric/puppet-dcos) [![Puppet Forge
Downloads](http://img.shields.io/puppetforge/dt/deric/dcos.svg)](https://forge.puppetlabs.com/deric/dcos/scores)

DC/OS nodes management

## Features

 * support running DC/OS on Debian based systems
 * manages agent's attributes

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

## YAML (Hiera/lookup) configuration

Simply use supported parameters:
```yaml
dcos::agent::mesos:
  MESOS_CGROUPS_ENABLE_CFS: false
dcos::master::mesos:
  MESOS_QUORUM: 2
```

## Limitations

Doesn't handle DC/OS installation, use one of officially supported methods.