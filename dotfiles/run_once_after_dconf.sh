#!/bin/bash
# Apply dconf settings that can't live in a dotfile

set -euo pipefail

dconf write /org/virt-manager/virt-manager/connections/autoconnect "['qemu:///system']"
dconf write /org/virt-manager/virt-manager/connections/uris "['qemu:///system']"
