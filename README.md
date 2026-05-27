# Kali Linux Browser Installer

This project provides a Bash script to install or repair Google Chrome and Brave Browser on Kali Linux.

## Supported Browsers

1. Google Chrome Stable
2. Brave Browser Stable

## Supported Operating System

This script is intended for Kali Linux and other Debian-based Linux distributions.

Tested target environment:

- Kali Linux
- Debian-based systems
- amd64 architecture

## Important Notes

Google Chrome official Linux package is available as a 64-bit `.deb` package for Debian and Ubuntu-based systems.

Brave Browser is installed using Brave's official APT repository. This allows Brave to receive updates through the normal `apt update` and `apt upgrade` process.

## Features

- Installs Google Chrome
- Installs Brave Browser
- Detects if browsers already exist
- Allows reinstall or repair
- Fixes broken dependencies
- Checks system architecture
- Uses official package sources
- Shows installed browser versions

## Files

```text
install_browsers.sh
README.md
