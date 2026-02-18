# Home router based on AlmaLinux or Fedora Server

[![GitHub license](https://img.shields.io/github/license/baxeno/home-router)](https://github.com/baxeno/home-router/blob/main/LICENSE)

This project setup a secure home router based on Linux using existing open source tools.
It started as just a simple Bash script and evolved into a few Ansible roles.

**Features:**

- Auto update OS
- IPv4 router
- DHCP server
- SSH server
- Firewall

**Supported OSes:**

AlmaLinux is recommended for supported hardware, as it comes with a 10-year lifecycle providing security updates and support.
Fedora Server is recommeded for new hardware and latest software features.

- AlmaLinux OS 10 (EoL ~2035)
- Fedora Server 43
- Fedora Server 42
- Fedora Server 41 (EoL 2025-11-26)
- Fedora Server 40 (EoL 2025-05-13)

> Migrate installations before OS reach End of Life (EoL)
> [Fedora End of Life Releases](https://docs.fedoraproject.org/en-US/releases/eol/)

**WIP OSes:**

- CentOS Stream 10 (WIP, EoL 2030-05-31)

## Install

**Prerequisites:**

- Install [Fedora Server](https://fedoraproject.org/server/) or [AlmaLinux](https://almalinux.org/get-almalinux/) on bare metal router hardware
  - Architecture: `x86_64` or `aarch64`
  - 2 x Ethernet NICs
- Setup ed25519 authorized key for ssh access as password login is disabled
  - `ssh-copy-id -i ~/.ssh/id_ed25519.pub ${USER}@${HOME_ROUTER_IP}`

**Released version:**

```bash
# Download and extract latest release
curl https://codeload.github.com/baxeno/home-router/tar.gz/refs/tags/v0.3.0 -o home-router-v0.3.0.tar.gz
tar -xvzf home-router-v0.3.0.tar.gz
cd home-router-0.3.0/ansible

# Install basic Ansible host dependencies
sudo dnf install -y ansible-core
ansible-galaxy collection install -r requirements.yml

# Update `inventory/localhost.yml` with interfaces and maybe some of the optional parameters
ansible-playbook --check -K -i inventory/localhost.yml home-router.yml
```

Ansible inventory configuration:

`router_lan_subnet` and `dhcp_router_ip` variables are automatically calculated based on `router_lan_network`.

**Development snapshot:**

Install from git using Bash script:

```bash
sudo dnf install -y git
git clone https://github.com/baxeno/home-router.git
cd home-router/bash
# Update script with interfaces and possible one of the optional parameters
sudo ./setup-router.sh
```

Install from git using Ansible:

```bash
sudo dnf install -y git ansible-core
ansible-galaxy collection install -r ansible/requirements.yml
git clone https://github.com/baxeno/home-router.git
cd home-router/ansible
# Update inventory file with your configuration
ansible-playbook --check -K -i inventory/localhost.yml home-router.yml
```

## Used tools

- [Fedora Server](https://fedoraproject.org/server/) - Run server workloads on bare metal or virtual machines with the latest open source technologies curated by the Fedora Community.
- [DNF automatic](https://github.com/rpm-software-management/dnf) - Package manager - automated upgrades.
- [firewalld](https://firewalld.org/) - A firewall daemon with D-Bus interface providing a dynamic firewall.
- [NetworkManager](https://networkmanager.dev/) - NetworkManager is the standard Linux network configuration tool suite.
- [Kea DHCP](https://www.isc.org/kea/) - Modern, open source DHCPv4 & DHCPv6 server.
- [ISC DHCP](https://www.isc.org/dhcp/) - Enterprise-grade solution for IP address-configuration needs.
- [OpenSSH](https://www.openssh.com/) - SSH.... keeping your communiqués secret.

**Used tools (Bash only):**

- [gettext-envsubst](https://www.gnu.org/software/gettext/) - Substitutes the values of environment variables.
- [patch](https://savannah.gnu.org/projects/patch/) - The patch program applies diff files to originals.

