auto-update
===========

Setup DNF4/DNF5 based weekly automatic updates on host.

Requirements
------------

Fedora 41, 42, 43, 44
AlmaLinux 10

Role Variables
--------------

This roles does not have any settable variables.

Dependencies
------------

os-requirements

Example Playbook
----------------

Role can be used like this

    - hosts: routers
      roles:
         - os-requirements
         - auto-update

License
-------

Apache-2.0

Author Information
------------------

https://github.com/baxeno/home-router

