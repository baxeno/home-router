# Home router based on AlmaLinux OS or Fedora Linux

[![GitHub License](https://img.shields.io/github/license/baxeno/home-router?style=for-the-badge&cacheSeconds=3600)](https://github.com/baxeno/home-router/blob/main/LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/baxeno/home-router?sort=semver&display_name=tag&style=for-the-badge&cacheSeconds=3600)](https://github.com/baxeno/home-router/releases)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/baxeno/home-router/ansible-lint.yml?branch=main&event=push&style=for-the-badge&label=ansible%20lint&cacheSeconds=3600)
![Self-hosted](https://img.shields.io/badge/Self%20Hosted-yes-00C7B7?style=for-the-badge)

Setup a secure router for home or small office use.
Based on a modern open-source foundation using Linux distributions like AlmaLinux OS, Fedora Linux or CentOS Stream.
It require no data sharing or persistent cloud connection for being eligible to receive software updates.
AlmaLinux OS (ISO Image/Server Admin) is recommended for supported hardware, as it comes with a 10-year lifecycle providing security updates and support.
Fedora Linux (Server edition) is recommended for new hardware and latest software features.
Create a single Ansible inventory file based on [`inventory/localhost.yml`](ansible/inventory/localhost.yml) with your router configuration and you are ready to deploy.

**Features:**

- Core router features
  - IPv4 router
  - DHCPv4 server
  - Firewall
- Maintenance features
  - Automatically system update and reboot if needed
- Management features
  - SSH server for local on-prem management (re-run Ansible playbook)
- Monitoring features
  - Basic (`htop`) system monitoring
  - Advanced (`glances`) system monitoring that is very good at highlighting the most important metric

**Supported OSes:**

- AlmaLinux OS 10 (EoL 2035-05-31)
- AlmaLinux OS 9 (EoL 2032-05-31)
- Fedora Linux 44 (EoL 2027-05-19)
- Fedora Linux 43 (EoL 2026-12-02)
- Fedora Linux 42 (EoL 2026-05-13)
- Fedora Linux 41 (EoL 2025-11-26)
- CentOS Stream 10 (EoL 2030-05-31)

Migrate installations before OS reach End of Life (EoL), see more info below:

- [AlmaLinux EoL](https://endoflife.date/almalinux)
- [Fedora Linux EoL](https://endoflife.date/fedora) / [Fedora End of Life Releases](https://docs.fedoraproject.org/en-US/releases/eol/)
- [CentOS Stream EoL](https://endoflife.date/centos-stream)

Fedora vs Enterprise Linux versions:

- Fedora 34 == AlmaLinux OS 9
- Fedora 40 == AlmaLinux OS 10 / CentOS Stream 10

## Install

**Prerequisites:**

- Install [Fedora Server](https://fedoraproject.org/server/) or [AlmaLinux OS](https://almalinux.org/get-almalinux/) on bare metal router hardware
  - Architecture:
    - `x86_64`
    - `x86_64 v2` (only AlmaLinux OS 10)
    - `aarch64`
  - 2 x Ethernet NICs

**Released version:**

```bash
# Install basic Ansible host dependencies
sudo dnf install -y ansible-core

# Download and extract latest release
curl https://codeload.github.com/baxeno/home-router/tar.gz/refs/tags/v0.6.0 -o home-router-v0.6.0.tar.gz
tar -xvzf home-router-v0.6.0.tar.gz

cd home-router-0.6.0/ansible
# Update `inventory/localhost.yml` with interfaces and maybe some of the optional parameters
ansible-playbook -K -i inventory/localhost.yml home-router.yml
```

Ansible inventory configuration:

`router_lan_subnet` and `dhcp_router_ip` variables are automatically calculated based on `router_lan_network`, but can still be overridden in an inventory file.

## FAQ

### What is the best DNS resolver option?

It depends on where in the world you are located, but a general recommendation is to use a DNS resovler that filters domains that are classified as malicious.

- DNS4EU For Public - Protective resolution
  - Primary DNS: 86.54.11.1
  - Secondary DNS: 86.54.11.201
  - [DNS4EU for Public: Resolver Options and IP addresses](https://joindns4.eu/for-public#resolver-options)
- Cloudflare (1.1.1.1) for Families - Block malware
  - Primary DNS: 1.1.1.2
  - Secondary DNS: 1.0.0.3
  - [Cloudflare 1.1.1.1 (DNS resolver) Set up](https://developers.cloudflare.com/1.1.1.1/setup/)
- Quad9 (9.9.9.9) - Secure
  - Primary DNS: 9.9.9.9
  - Secondary DNS: 149.112.112.112
  - [Quad9 Services](https://docs.quad9.net/services/)

### Why is there no support for WiFi Access Point (AP) feature?

It is possible to setup WiFi APs using a WiFi client USB dongle, but don't expect more then ~150MBit/s at ~1 meter range with a single WiFi client.
WiFi APs require specific WiFi chips with many antennas and they are only sold to big COTS manufactures.
Linux kernel upstream support of these chips are typically lacking.
This is also why COTS routers with WiFi AP builtin don't receive updates as they are carrying large patch series that require a lot of work to rebase onto a new kernel release.

Recommended action is to have separate hardware for router and WiFi APs.

### Why not just use a common Asus, D-Link, Linksys, Netgear home router with WiFi AP?

Commercially available off-the-shelf (COTS) router products typically receive very few security updates during there life-time.
This result in them being compromised and used in large botnets and/or as AI scraper proxies which result in slower internet speeds for home users.

**Examples:**

- June 2026 [These 5 Routers Are No Longer Safe To Use After A New Security Backdoor Was Discovered](https://www.bgr.com/2215770/tenda-router-security-backdoor-cert-safety/)
  - Multiple Tenda WiFi routers contain admin backdoor
- June 2026 [RustDuck Botnet Rebuilds in Rust to Hijack Routers and Servers for DDoS](https://thehackernews.com/2026/06/rustduck-botnet-rebuilds-in-rust-to.html)
  - RustDuck is hijacking home routers, IP cameras, Android boxes, and poorly secured servers.
  - Huawei, D-Link and Totolink routers.
- June 2026 [AryStinger Malware Infects 4,300 Legacy Routers to Build Reconnaissance Proxy Network](https://thehackernews.com/2026/06/arystinger-malware-infects-4300-legacy.html)
  - The campaign goes after routers built on Realtek's RTL819X chips, hardware that was current around 2012 to 2015.
  - The infected pool is mostly D-Link, with the DIR-850L alone making up about 75 percent.
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

### What IP range should I use?

There are 3 standard private IPv4 ranges:

  - 10.0.0.0 - 10.255.255.255 (10.0.0.0/8)
    - Very large networks
  - 172.16.0.0 - 172.32.255.255 (172.16.0.0/12)
    - Medium-size networks
  - 192.168.0.0 - 192.168.255.255 (192.168.0.0/16) **Recommended**
    - Home and small offices networks

Avoid special local ranges:

  - 127.0.0.0 - 127.255.255.255 (127.0.0.0/8)
    - Loopback addresses used by localhost.
  - 169.254.0.0 - 169.254.255.255 (169.254.0.0/16)
    - Link-local addresses assigned automatically when no DHCP server is found on the network.

### What is a modern open-source foundation?

|Vintage|Modern|Reasoning|
|---|---|---|
| `SysV Init`, `Busybox runit` | `systemd` | Better service management, resource tracking, log tagging, sandboxing with `cgroups` and `namespaces`. |
| `iptables`, `ip6tables` | `firewalld` (`nftables`) | Easier firewalling for each interface using zones. |
| `ISC DHCP (dhcpd)`, `dnsmasq` | `Kea DHCP` | Fully featured DHCPv4 and DHCPv6 server with structured JSON configuration file. |
| `udhcpc`, `ifconfig` | `NetworkManager` | Networking that Just Works, DHCPv4 and IPv6 autoconfiguration. |
| `openssh`, `dropbear` | `openssh` | A true classic never goes out of style. OpenSSH has been continuously been updated with better ciphers and internal software architecture. |
| `openntpd` | `chrony` | Full NTS support for authenticated time sync. |
| `avahi` | `systemd-resolved` | DNS resolver with DNSSEC, DoH, DoT and mDNS support. |
| `eth0`, `eth1` | `ens1`, `enp2s0`, `enp2s0f0` | [Predictable Network Interface Names](https://systemd.io/PREDICTABLE_INTERFACE_NAMES/) |

## Used tools

The following open-source software components are used.

- [AlmaLinux OS](https://almalinux.org/get-almalinux/) - An Open Source, community owned and governed, forever-free enterprise Linux distribution, focused on long-term stability, providing a robust production-grade platform.
- [Fedora Server](https://fedoraproject.org/server/) - Run server workloads on bare metal or virtual machines with the latest open source technologies curated by the Fedora Community.
- [DNF automatic](https://github.com/rpm-software-management/dnf) - Package manager - automated upgrades.
- [firewalld](https://firewalld.org/) - A firewall daemon with D-Bus interface providing a dynamic firewall.
- [NetworkManager](https://networkmanager.dev/) - NetworkManager is the standard Linux network configuration tool suite.
- [Kea DHCP](https://www.isc.org/kea/) - Modern, open source DHCPv4 & DHCPv6 server.
- [OpenSSH](https://www.openssh.com/) - SSH.... keeping your communiqués secret.
- [Chrony](https://chrony-project.org/) - chrony is a versatile implementation of the Network Time Protocol (NTP).
- [systemd-resolved](https://www.freedesktop.org/software/systemd/man/latest/systemd-resolved.service.html) - Network Name Resolution manager.
- [htop](https://htop.dev/) / [htop github](https://github.com/htop-dev/htop) - interactive process viewer.
- [glances](https://nicolargo.github.io/glances/) / [glances github](https://github.com/nicolargo/glances) - An Eye on your System.

**Documentation links:**

- [Kea DHCPv4 Server configuration](https://kea.readthedocs.io/en/latest/arm/dhcp4-srv.html#dhcpv4-server-configuration)

## Contributing

Feel free to open bug reports or feature requests in [Issues section](https://github.com/baxeno/home-router/issues).

## Development

Install from git using Ansible:

```bash
# Install basic Ansible host dependencies
sudo dnf install -y git ansible-core

# Download latest development version
git clone https://github.com/baxeno/home-router.git

cd home-router/ansible
# Update `inventory/localhost.yml` with interfaces and maybe some of the optional parameters
ansible-playbook -K -i inventory/localhost.yml home-router.yml
```

Show Ansible facts for localhost:

```bash
ansible localhost -m ansible.builtin.setup
```

### Release flow

- Draft release notes in GitHub
- Update `README.md` examples with latest release version
- Tag git (Ex. `git tag -a v0.5.0`)
- Publish release notes in GitHub
