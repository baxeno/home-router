# Home router based on Fedora Server

[![GitHub license](https://img.shields.io/github/license/baxeno/home-router)](https://github.com/baxeno/home-router/blob/main/LICENSE)

This project helps you easiely setup a home router based on Fedora Server.

**Features:**

- Auto update OS
- IPv4 router
- DHCP server
- Firewall

**Prerequisites:**

- Install [Fedora Server](https://fedoraproject.org/server/) on base metal router hardware
  - Architecture: `x86_64` or `aarch64`
  - 2 x Ethernet NICs

**Install (from git):**

```bash
sudo dnf install -y git
git clone https://github.com/baxeno/home-router.git
cd home-router
# Update script with interfaces and possible one of the optional parameters
sudo ./setup-router.sh
```
