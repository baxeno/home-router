# Home router based on AlmaLinux or Fedora Server

[![GitHub license](https://img.shields.io/github/license/baxeno/home-router)](https://github.com/baxeno/home-router/blob/main/LICENSE)

This project aims to setup a secure home router appliance based on Linux with minimal maintenance using existing open source components.

**Features:**

- Core router features
  - IPv4 router
  - DHCPv4 server
  - Firewall
- Maintenance features
  - Automatically system update and reboot if needed
- Management features
  - SSH server for local onprem management

**Roadmap:**

- IPv6-Mostly router
  - [RFC 8925 IPv6-Only Preferred Option for DHCPv4 (option 108)](https://www.rfc-editor.org/rfc/rfc8925.txt)
  - [RFC 6877 464XLAT](https://www.rfc-editor.org/rfc/rfc6877.txt)
  - [RFC 8781 PREF64 option](https://www.rfc-editor.org/rfc/rfc8781.txt)

**Supported OSes:**

AlmaLinux is recommended for supported hardware, as it comes with a 10-year lifecycle providing security updates and support.
Fedora Server is recommeded for new hardware and latest software features.

- AlmaLinux OS 10 (EoL ~2035)
- Fedora Server 43
- Fedora Server 42 (EoL 2026-05-13)
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

## FAQ

### Why is there no support for WiFi Access Point (AP) feature?

It is possible to setup WiFi APs using a WiFi client USB dongle, but don't expect more then ~150MBit/s at ~1 meter range with a single WiFi client.
WiFi APs require specific WiFi chips with many antennas and they are only sold to big COTS manufactures.
Linux kernel upstream support of these chips are typically lacking.
This is also why COTS routers with WiFi AP builtin don't receive updates as they are carrying large patch series that require a lot of work to rebase onto a new kernel release.

Recommended action is to have seperate hardware for router and WiFi APs.

### Why not just use a common Asus, D-Link, Linksys, Netgear home router with WiFi AP?

Commercially available off-the-shelf (COTS) router products typically receive very few security updates during there life-time.
This result in them being compromised and used in large botnets and/or as AI scraper proxies which result in slower internet speeds for home users.

**Examples:**

- March 2026 [Authorities Disrupt SocksEscort Proxy Botnet Exploiting 369,000 IPs Across 163 Countries](https://thehackernews.com/2026/03/authorities-disrupt-socksescort-proxy.html)
  - Criminal proxy service named SocksEscort was powered by a malware known as AVrecon.
  - The malware targets approximately 1,200 device models manufactured by Cisco, D-Link, Hikvision, Mikrotik, NETGEAR, TP-Link, and Zyxel.
- March 2026 [New KadNap botnet hijacks ASUS routers to fuel cybercrime proxy network](https://www.bleepingcomputer.com/news/security/new-kadnap-botnet-hijacks-asus-routers-to-fuel-cybercrime-proxy-network/)
  - A newly discovered botnet malware called KadNap is targeting ASUS routers and other edge networking devices to turn them into proxies for malicious traffic.
- May 2025 [Police dismantles botnet selling hacked routers as residential proxies](https://www.bleepingcomputer.com/news/security/police-dismantles-botnet-selling-hacked-routers-as-residential-proxies/)
- May 2025 [FBI: End-of-life routers hacked for cybercrime proxy networks](https://www.bleepingcomputer.com/news/security/fbi-end-of-life-routers-hacked-for-cybercrime-proxy-networks/)
  - End of life routers were breached by cyber actors using variants of TheMoon malware botnet.
  - Common targets include Linksys and Cisco models.
- December 2024[Malware botnets exploit outdated D-Link routers in recent attacks](https://www.bleepingcomputer.com/news/security/malware-botnets-exploit-outdated-d-link-routers-in-recent-attacks/)
  - Two botnets tracked as ‘Ficora’ and ‘Capsaicin’ have recorded increased activity in targeting D-Link routers that have reached end of life or are running outdated firmware versions.
- September 2022 [Moobot botnet is coming for your unpatched D-Link router](https://www.bleepingcomputer.com/news/security/moobot-botnet-is-coming-for-your-unpatched-d-link-router/)
  - The Mirai malware botnet variant known as ‘MooBot’ has re-emerged in a new attack wave that started early last month, targeting vulnerable D-Link routers with a mix of old and new exploits.

## Used tools

The following open-source software components are used.

- [AlmaLinux OS](https://almalinux.org/get-almalinux/) - An Open Source, community owned and governed, forever-free enterprise Linux distribution, focused on long-term stability, providing a robust production-grade platform.
- [Fedora Server](https://fedoraproject.org/server/) - Run server workloads on bare metal or virtual machines with the latest open source technologies curated by the Fedora Community.
- [DNF automatic](https://github.com/rpm-software-management/dnf) - Package manager - automated upgrades.
- [firewalld](https://firewalld.org/) - A firewall daemon with D-Bus interface providing a dynamic firewall.
- [NetworkManager](https://networkmanager.dev/) - NetworkManager is the standard Linux network configuration tool suite.
- [Kea DHCP](https://www.isc.org/kea/) - Modern, open source DHCPv4 & DHCPv6 server.
- [OpenSSH](https://www.openssh.com/) - SSH.... keeping your communiqués secret.

**Documentation links:**

- [Kea DHCPv4 Server configuration](https://kea.readthedocs.io/en/latest/arm/dhcp4-srv.html#dhcpv4-server-configuration)

## Development

Feel free to open bug reports or feature requests in [Issues section](https://github.com/baxeno/home-router/issues).

Install from git using Ansible:

```bash
sudo dnf install -y git ansible-core
ansible-galaxy collection install -r ansible/requirements.yml
git clone https://github.com/baxeno/home-router.git
cd home-router/ansible
# Update inventory file with your configuration
ansible-playbook --check -K -i inventory/localhost.yml home-router.yml
```

