## Sensu-Plugins-chage

<!--
[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-skel.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-skel)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-skel.svg)](http://badge.fury.io/rb/sensu-plugins-skel)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-skel.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-skel)
-->

## Functionality
Check accounts for expiry using the `chage` tool.

## Files
* bin/check-password-expiry.rb

## Usage

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)

### `bin/check-password-expiry.rb`
Running the `chage` command on other accounts requires root access, so under the assumption that you don't run Sensu as root, you must grant sudo rights to the Sensu user to run `chage`.

This usually can be done as a file in `/etc/sudoers.d/`:
```
# replace 'sensu' below with the name of your Sensu user
sensu ALL = NOPASSWD: /usr/bin/chage -l *
```

## Notes
