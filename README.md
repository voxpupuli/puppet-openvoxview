# Puppet module for OpenVox View

[![Build Status](https://github.com/voxpupuli/puppet-openvoxview/workflows/CI/badge.svg)](https://github.com/voxpupuli/puppet-openvoxview/actions?query=workflow%3ACI)
[![Code Coverage](https://coveralls.io/repos/github/voxpupuli/puppet-openvoxview/badge.svg?branch=master)](https://coveralls.io/github/voxpupuli/puppet-openvoxview)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/openvoxview.svg)](https://forge.puppetlabs.com/puppet/openvoxview)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/openvoxview.svg)](https://forge.puppetlabs.com/puppet/openvoxview)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/openvoxview.svg)](https://forge.puppetlabs.com/puppet/openvoxview)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/openvoxview.svg)](https://forge.puppetlabs.com/puppet/openvoxview)
[![License](https://img.shields.io/github/license/voxpupuli/puppet-openvoxview.svg)](https://github.com/voxpupuli/puppet-openvoxview/blob/main/LICENSE)

## Table of Contents

1. [Description](#description)
1. [Usage](#usage)
1. [Development - Guide for contributing to the module](#development)

## Description

This module installs and configures [OpenVoxView](https://github.com/voxpupuli/openvoxview)

## Usage

```puppet
include openvoxview
```


Install specific version of OpenVox View

```puppet
class { 'openvoxview':
  version        => '0.1.12',
}
```

## Reference

[Reference][1]

## Development

Feel free to create issues or send PRs. never forget, be excellent to each other!


## Installation Notes

When installing, the following steps will be performed:

The selected version will be downloaded to **/opt/openvoxview-$version**, a symbolic link will be created/updated at **/usr/local/bin/openvoxview**

### Important

Older versions located in `/opt/openvoxview-*` will **not** be removed automatically.
If you wish to free up disk space or remove outdated versions, please delete them manually.

## Author

This module is maintained by [Vox Pupuli][2]. It was originally written and
maintained by [Sebastian Rakel][3].

[1]: https://github.com/voxpupuli/puppet-openvoxview/blob/master/REFERENCE.md
[2]: https://voxpupuli.org
[3]: https://github.com/SebastianRakel
