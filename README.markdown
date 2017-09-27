## puppet-dcos

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

Master node:

```puppet
class{'dcos::master':
  config => {
    'MESOS_QUORUM' => 2,
    'MESOS_max_completed_frameworks' => 50,
    'MESOS_max_completed_tasks_per_framework' => 1000,
    'MESOS_max_unreachable_tasks_per_framework' => 1000,
  }
}
```
`config` will create a `/opt/mesosphere/etc/mesos-master-extras` overriding default `ENV` variables.

attributes:
```yaml
dcos::agent::attributes:
  dc: us-east
  storage: SATA
```

## Limitations

Doesn't handle DC/OS installation, use one of officially supported methods.