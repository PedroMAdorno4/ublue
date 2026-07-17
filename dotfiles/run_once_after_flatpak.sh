#!/bin/bash
# Install flatpak apps and bring existing ones up to date

set -euo pipefail

flatpak install -y --noninteractive flathub \
    org.mozilla.firefox \
    org.freecad.FreeCAD \
    com.slack.Slack \
    com.orcaslicer.OrcaSlicer

# Remove unwanted apps that ship preinstalled on the base image
flatpak uninstall -y --noninteractive \
    org.kde.okular \
    org.kde.haruna \
    || true

flatpak update -y --noninteractive
