# Home router based on AlmaLinux or Fedora Server

![GitHub License](https://img.shields.io/github/license/baxeno/home-router?cacheSeconds=86400&link=https%3A%2F%2Fgithub.com%2Fbaxeno%2Fhome-router%2Fblob%2Fmain%2FLICENSE)

This project aims to setup a secure home router appliance based on a standard Linux distribution (AlmaLinux or Fedora) with minimal maintenance using existing open source components.

**Features:**

- Core router features
  - IPv4 router
  - DHCPv4 server
  - Firewall
- Maintenance features
  - Automatically system update and reboot if needed
- Management features
  - SSH server for local on-prem management

**Supported OSes:**

AlmaLinux is recommended for supported hardware, as it comes with a 10-year lifecycle providing security updates and support.
Fedora Server is recommeded for new hardware and latest software features.

- AlmaLinux OS 10 (EoL ~2035)
- Fedora Server 44 (EoL 2027-05-19)
- Fedora Server 43 (EoL 2026-12-02)
- Fedora Server 42 (EoL 2026-05-13)
- Fedora Server 41 (EoL 2025-11-26)
- CentOS Stream 10 (EoL 2030-05-31)

> Migrate installations before OS reach End of Life (EoL)
> [Fedora End of Life Releases](https://docs.fedoraproject.org/en-US/releases/eol/)

## Install

**Prerequisites:**

- Install [Fedora Server](https://fedoraproject.org/server/) or [AlmaLinux](https://almalinux.org/get-almalinux/) on bare metal router hardware
  - Architecture: `x86_64` or `aarch64`
  - 2 x Ethernet NICs
- Setup ed25519 authorized key for ssh access as password login is disabled
  - `ssh-copy-id -i ~/.ssh/id_ed25519.pub ${USER}@${HOME_ROUTER_IP}`

**Released version:**

```bash
# Install basic Ansible host dependencies
sudo dnf install -y ansible-core

# Download and extract latest release
curl https://codeload.github.com/baxeno/home-router/tar.gz/refs/tags/v0.4.0 -o home-router-v0.4.0.tar.gz
tar -xvzf home-router-v0.4.0.tar.gz

cd home-router-0.4.0/ansible
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
