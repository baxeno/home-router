# Home router based on Fedora Server

**Prerequisites:**

- Install [Fedora Server](https://fedoraproject.org/server/) on base metal router hardware
  - Architecture x86_64 or aarch64
  - 2 x Ethernet NICs
- Install RPM packages
  - `sudo dnf install -y git dhcp-server gettext-envsubst`

**Install:**

```bash
git clone https://github.com/baxeno/home-router.git
cd home-router
# Update script with WAN_INTERFACE and LAN_INTERFACE
./setup-router.sh
```
