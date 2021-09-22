#!/bin/bash

cp -rf hardening.yml /etc/ansible/
cp -rf linux-system-roles.selinux/ os-hardening/ ssh-hardening/ /root/.ansible/roles/
