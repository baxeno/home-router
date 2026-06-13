Role Name
=========

Setup router based on Linux, systemd, Kea DHCP, NetworkManager and firewalld.

Requirements
------------

Must be run on a supported OS, see `os-requirements` role.

Role Variables
--------------

The following variables need to be set in inventory file:
- `router_wan_interface`: Device name of WAN network interface (internet).
- `router_lan_interface`: Device name of LAN network interface (home network).

Device name (`<DEVICE>`) of network interfaces can be found with `nmcli` which output `<DEVICE>: connected on <NAME>`.

The following variables can be set in inventory file:
- `router_bridge_interface`: Interface is used for routing packages between `router_lan_interface` and `router_wan_interface`.
- `router_hostname`: Hostname of router when accessing it from LAN (home) network.
- `router_domain`: ICANN has created .internal TLD for private use. Unsupported at the moment.
- `router_lan_network`: Contain IP address for router LAN interface and home network size in CIDR Subnet Mask Notation.
- `dhcp_primary_dns`: Primary DNS server given to DHCP clients.
- `dhcp_secondary_dns`: Secondary DNS server given to DHCP clients.
- `dhcp_client_pool_start`: First IP address given to DHCP clients.
- `dhcp_client_pool_end`: Last IP address given to DHCP clients.

The following variables are automatically calculated based on other variables.
- `router_lan_subnet`: Calculated based on `router_lan_network`.
- `dhcp_router_ip`: Calculated based on `router_lan_network`.

Dependencies
------------

The following role must be run before this:
- `os-requirements`

Example Playbook
----------------

See `home-router.yml`

License
-------

Apache-2.0

Author Information
------------------

https://github.com/baxeno/home-router
