# Home router based on Fedora Server

[![GitHub license](https://img.shields.io/github/license/baxeno/home-router)](https://github.com/baxeno/home-router/blob/main/LICENSE)

This project setup a secure home router based on Fedora Server using existing open source tools.

**Features:**

- Auto update OS
- IPv4 router
- DHCP server
- SSH server
- Firewall

**Used tools:**

- [Fedora Server](https://fedoraproject.org/server/) - Run server workloads on bare metal or virtual machines with the latest open source technologies curated by the Fedora Community.
- [DNF automatic](https://github.com/rpm-software-management/dnf) - Package manager - automated upgrades.
- [firewalld](https://firewalld.org/) - A firewall daemon with D-Bus interface providing a dynamic firewall.
- [NetworkManager](https://networkmanager.dev/) - NetworkManager is the standard Linux network configuration tool suite.
- [ISC DHCP](https://www.isc.org/dhcp/) - Enterprise-grade solution for IP address-configuration needs.
- [OpenSSH](https://www.openssh.com/) - SSH.... keeping your communiqués secret.
- [gettext-envsubst](https://www.gnu.org/software/gettext/) - Substitutes the values of environment variables.
- [patch](https://savannah.gnu.org/projects/patch/) - The patch program applies diff files to originals.

**Future tools:**

- [Kea DHCP](https://www.isc.org/kea/) - Modern, open source DHCPv4 & DHCPv6 server.

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
