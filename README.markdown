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

attributes:
```yaml
dcos::agent::attributes:
  dc: us-east
  storage: SATA
```

## Limitations

Doesn't handle DC/OS installation, use one of officially supported methods.