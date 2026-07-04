#!/bin/bash

set -ouex pipefail

# Copy system_files/ to /
cp -avf "/ctx/system_files"/. /

### Repos

# RPMFusion (free + nonfree) is available by default on ublue images
# COPR repos needed for some packages
dnf5 -y copr enable atim/lazygit
dnf5 -y copr enable atim/btop
dnf5 -y copr enable atim/lazydocker
dnf5 -y copr enable wef/lact
dnf5 -y copr enable rodoma92/ydotool
dnf5 -y copr enable lionheartp/Hyprland

### System packages

dnf5 install -y \
    zsh \
    git \
    vim \
    neovim \
    tmux \
    kitty \
    fzf \
    ripgrep \
    fd-find \
    jq \
    socat \
    yazi \
    lazygit \
    lazydocker \
    btop \
    fastfetch \
    mpv \
    zathura \
    zathura-pdf-poppler \
    playerctl \
    pamixer \
    pavucontrol \
    pwvucontrol \
    wl-clipboard \
    libnotify \
    killall \
    util-linux \
    p7zip \
    p7zip-plugins \
    unzip \
    zip \
    unrar \
    aria2 \
    usbutils \
    pciutils \
    dmidecode \
    lshw \
    parted \
    cryptsetup \
    ntfs-3g \
    exfatprogs \
    age \
    sops \
    android-tools \
    arduino-cli \
    tio \
    putty \
    poppler-utils \
    f3d \
    delta \
    sad \
    timg \
    peaclock \
    xdg-utils \
    xwayland-run \
    wayland-utils \
    wlprop \
    slurp \
    grim \
    satty \
    swappy \
    wofi \
    waybar \
    wlogout \
    hyprpicker \
    hyprlock \
    hyprpolkitagent \
    uwsm \
    niri \
    hyprland \
    xdg-desktop-portal-gtk \
    xdg-desktop-portal-gnome \
    blueman \
    gamemode \
    mangohud \
    mangojuice \
    steam \
    lutris \
    heroic-games-launcher \
    prismlauncher \
    discord \
    brave-browser \
    firefox \
    filezilla \
    transmission-gtk \
    inkscape \
    blender \
    gimp \
    koreader \
    obs-studio \
    godot \
    distrobox \
    flatpak \
    protonup-qt \
    ffmpeg \
    mpvpaper \
    wl-screenrec \
    vulkan-tools \
    clinfo \
    amdgpu_top \
    lact \
    ydotool \
    openvpn \
    magic-wormhole \
    rpi-imager \
    baobab \
    gcc \
    cargo \
    rustc \
    direnv \
    eza \
    handlr-regex \
    gnupg2 \
    pinentry-curses \
    openssh-server \
    cups \
    cups-filters \
    avahi \
    gvfs \
    udisks2 \
    earlyoom \
    virt-manager \
    libvirt \
    qemu-kvm \
    qemu-virtiofsd \
    spice-vdagent \
    dnsmasq \
    podman \
    podman-compose \
    dive \
    podman-tui \
    sunshine \
    fcitx5 \
    fcitx5-gtk \
    fcitx5-mozc \
    waybar \
    upower \
    polkit-gnome \
    noctalia-git \
    hyprshot \
    brightnessctl \
    wofi-emoji \
    bibata-cursor-themes

# Disable COPRs so they don't persist in the final image
dnf5 -y copr disable atim/lazygit
dnf5 -y copr disable atim/btop
dnf5 -y copr disable atim/lazydocker
dnf5 -y copr disable wef/lact
dnf5 -y copr disable rodoma92/ydotool
dnf5 -y copr disable lionheartp/Hyprland

### Fonts

dnf5 install -y \
    jetbrains-mono-fonts-all \
    google-noto-fonts-common \
    google-noto-emoji-color-fonts \
    twemoji-color-fonts \
    fontawesome-fonts \
    'cascadia-*-nerd-font' \
    'jetbrains-mono-*-nerd-font' \
    'fira-code-*-nerd-font'

### Services

# Core services already enabled by bazzite base, enable additional ones:
systemctl enable earlyoom.service
systemctl enable libvirtd.service || true
systemctl enable bluetooth.service
systemctl enable docker.service
systemctl enable docker.socket
systemctl enable tailscaled.service
systemctl enable lactd.service
systemctl enable flatpak-system-update.timer

# Avahi for mDNS
systemctl enable avahi-daemon.service

# Samba for file sharing
systemctl enable smb.service
systemctl enable nmb.service

# GNOME keyring
systemctl enable --global gnome-keyring-secrets.service || true

### oh-my-posh (not in Fedora repos, install from GitHub)
OMP_VERSION="$(curl -s https://api.github.com/repos/JanDeDobbeleer/oh-my-posh/releases/latest | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')"
curl -fsSL "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64" -o /usr/local/bin/oh-my-posh
chmod +x /usr/local/bin/oh-my-posh

### antidote (zsh plugin manager)
git clone --depth=1 https://github.com/getantidote/antidote.git /usr/share/antidote

### wl-gammarelay-rs (Wayland gamma/temperature control, not in Fedora repos)
cargo install wl-gammarelay-rs --root /usr/local

### Cleanup
dnf5 clean all
