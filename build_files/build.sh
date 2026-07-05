#!/bin/bash

set -ouex pipefail

# Copy system_files/ to /
cp -avf "/ctx/system_files"/. /

# Bake dotfiles/ into the image so chezmoi can apply them without network access
mkdir -p /usr/share/ublue-dotfiles
cp -avr "/ctx/dotfiles"/. /usr/share/ublue-dotfiles/

### Repos

# RPMFusion (free + nonfree) is available by default on ublue images
# COPR repos needed for some packages
dnf5 -y copr enable atim/lazygit
dnf5 -y copr enable lionheartp/Hyprland
dnf5 -y copr enable solopasha/hyprland

# Terra repo (https://terra.fyralabs.com) for packages missing from the base repos
dnf5 install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release

# Brave repo (https://brave.com/linux/) for brave-browser
dnf5 config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

### System packages

# Keep downloaded RPMs in the /var/cache cache mount across builds instead of
# deleting them right after install (Fedora's default keepcache=0 would
# otherwise defeat the --mount=type=cache,dst=/var/cache in the Containerfile,
# forcing every rebuild to re-download every package from the network).
dnf5 config-manager setopt keepcache=1

dnf5 install -y --skip-unavailable \
    zsh \
    git \
    chezmoi \
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
    psmisc \
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
    python3-magic-wormhole \
    rpi-imager \
    baobab \
    gcc \
    cargo \
    rustc \
    tree-sitter-cli \
    gopls \
    clang-tools-extra \
    python3-lsp-server \
    nodejs-bash-language-server \
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
    samba \
    dive \
    podman-tui \
    sunshine \
    fcitx5 \
    fcitx5-gtk \
    fcitx5-mozc \
    upower \
    noctalia-git \
    hyprshot \
    brightnessctl \
    wofi-emoji \
    bibata-cursor-theme \
    util-linux-user \
    qt5ct \
    qt6ct \
    breeze-icon-theme \
    adw-gtk3-theme \
    nodejs

# Disable COPRs so they don't persist in the final image
dnf5 -y copr disable atim/lazygit
dnf5 -y copr disable lionheartp/Hyprland
dnf5 -y copr disable solopasha/hyprland

### Fonts

dnf5 install -y \
    jetbrains-mono-fonts-all \
    google-noto-fonts-common \
    google-noto-emoji-color-fonts \
    twitter-twemoji-fonts \
    fontawesome-fonts-all \
    cascadia-code-nf-fonts \
    cascadia-mono-nf-fonts \
    fira-code-fonts

# JetBrains Mono Nerd Font (not in Fedora repos)
mkdir -p /usr/share/fonts/JetBrainsMonoNerdFont
curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" \
    | tar -xJ -C /usr/share/fonts/JetBrainsMonoNerdFont/
fc-cache -f /usr/share/fonts/JetBrainsMonoNerdFont/

### Services

# Core services already enabled by bazzite base, enable additional ones:
systemctl enable earlyoom.service
systemctl enable libvirtd.service || true
systemctl enable bluetooth.service
systemctl enable tailscaled.service
systemctl enable lactd.service || true
systemctl enable flatpak-system-update.timer || true

# Avahi for mDNS
systemctl enable avahi-daemon.service

# Samba for file sharing
systemctl enable smb.service
systemctl enable nmb.service

# GNOME keyring
systemctl enable --global gnome-keyring-secrets.service || true

# chezmoi dotfiles apply on first login
systemctl enable --global chezmoi-init.service || true

### oh-my-posh (not in Fedora repos, install from GitHub)
curl -fsSL "https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64" -o /usr/bin/oh-my-posh
chmod +x /usr/bin/oh-my-posh

### antidote (zsh plugin manager)
git clone --depth=1 https://github.com/getantidote/antidote.git /usr/share/antidote

### wl-gammarelay-rs (Wayland gamma/temperature control, not in Fedora repos)
CARGO_HOME=/tmp/cargo cargo install wl-gammarelay-rs --root /usr

### matugen (Material-You palette generator, not in Fedora repos)
# Release asset filenames embed the version, so the /latest/download/ shortcut
# doesn't work here (unlike oh-my-posh above) -- resolve the tag via the API first.
MATUGEN_TAG=$(curl -fsSL "https://api.github.com/repos/InioX/matugen/releases/latest" | jq -r .tag_name)
MATUGEN_VERSION="${MATUGEN_TAG#v}"
curl -fsSL "https://github.com/InioX/matugen/releases/download/${MATUGEN_TAG}/matugen-${MATUGEN_VERSION}-x86_64.tar.gz" \
    | tar -xzf - -C /usr/bin/ matugen
chmod +x /usr/bin/matugen

### Cleanup
# Note: intentionally not running `dnf5 clean all` here. /var/cache is a
# buildah cache mount (--mount=type=cache in the Containerfile), so its
# contents are never part of the committed image layer regardless of whether
# they're cleaned -- but wiping it here would defeat the point of the cache
# mount by forcing every subsequent build to re-download every RPM.
