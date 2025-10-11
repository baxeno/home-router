# Home router based on Fedora Server

[![GitHub license](https://img.shields.io/github/license/baxeno/home-router)](https://github.com/baxeno/home-router/blob/main/LICENSE)

This project setup a secure home router based on Fedora Server using existing open source tools.
It started as just a simple Bash script and evolved into a few Ansible roles.

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

**Used tools (Bash only):**

- [gettext-envsubst](https://www.gnu.org/software/gettext/) - Substitutes the values of environment variables.
- [patch](https://savannah.gnu.org/projects/patch/) - The patch program applies diff files to originals.

**Future tools:**

- [Kea DHCP](https://www.isc.org/kea/) - Modern, open source DHCPv4 & DHCPv6 server.

**Prerequisites:**

- Install [Fedora Server](https://fedoraproject.org/server/) on base metal router hardware
  - Architecture: `x86_64` or `aarch64`
  - 2 x Ethernet NICs
- Setup ed25519 authorized key for ssh access as password login is disabled
  - `ssh-copy-id -i ~/.ssh/id_ed25519.pub ${USER}@${HOME_ROUTER_IP}`

**Install (from git) using Bash script:**

```bash
sudo dnf install -y git
git clone https://github.com/baxeno/home-router.git
cd home-router/bash
# Update script with interfaces and possible one of the optional parameters
sudo ./setup-router.sh
```

**Install (from git) using Ansible:**

```bash
sudo dnf install -y git ansible
git clone https://github.com/baxeno/home-router.git
cd home-router
ansible-playbook --check -K ansible/home-router.yml
```

