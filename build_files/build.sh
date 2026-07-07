#!/bin/bash

set -ouex pipefail

# /root and /usr/local are symlinks to /var/roothome and /var/usrlocal, normally
# materialized at boot by rpm-ostree-0-integration.conf's systemd-tmpfiles rule,
# which never runs during image build. Without these, anything that mkdirs
# through the dangling symlinks (devbox's installer, `npm install -g`) fails.
mkdir -p /var/roothome /var/usrlocal

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
dnf5 -y copr enable hazel-bunny/ricing
dnf5 -y copr enable grahamwhiteuk/bruno
dnf5 -y copr enable vertigo-red/bottles

# Terra repo (https://terra.fyralabs.com) for packages missing from the base repos
# terra-release already ships in the bazzite base image with its repos disabled by
# default, so just enable them instead of redefining "terra" via --repofrompath
# (which collides with the existing repo id and fails with "Id is present more
# than once in the configuration").
dnf5 config-manager setopt terra.enabled=1 terra-extras.enabled=1 terra-mesa.enabled=1

# Brave repo (https://brave.com/linux/) for brave-browser
dnf5 config-manager addrepo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo

### System packages

# Keep downloaded RPMs in the /var/cache cache mount across builds instead of
# deleting them right after install (Fedora's default keepcache=0 would
# otherwise defeat the --mount=type=cache,dst=/var/cache in the Containerfile,
# forcing every rebuild to re-download every package from the network).
dnf5 config-manager setopt keepcache=1

# --skip-broken drops packages with unresolvable deps (e.g. colloid-gtk-theme
# needs the now-retired gnome-themes-extra; quickemu needs mesa-demos, which
# the bazzite base excludes) instead of failing the whole transaction.
dnf5 install -y --skip-unavailable --skip-broken \
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
    wlogout \
    hyprpicker \
    hyprlock \
    hyprpolkitagent \
    niri \
    hyprland \
    quickshell \
    xwayland-satellite \
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
    vesktop \
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
    quickemu \
    spice-vdagent \
    spice-gtk3 \
    spice-glib \
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
    colloid-gtk-theme \
    nodejs \
    nodejs-npm \
    bruno \
    bottles \
    wev

### LibreOffice (nix config used the qt6 build; libreoffice-kf6 is Fedora's closest analog)
dnf5 install -y --skip-unavailable \
    libreoffice-kf6 \
    libreoffice-writer \
    libreoffice-calc \
    libreoffice-impress

# Disable COPRs so they don't persist in the final image
dnf5 -y copr disable atim/lazygit
dnf5 -y copr disable lionheartp/Hyprland
dnf5 -y copr disable solopasha/hyprland
dnf5 -y copr disable hazel-bunny/ricing
dnf5 -y copr disable grahamwhiteuk/bruno
dnf5 -y copr disable vertigo-red/bottles

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
# systemctl enable earlyoom.service
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
# doesn't work here (unlike oh-my-posh above) -- resolve the tag by following
# the /releases/latest redirect instead of the api.github.com endpoint, which
# is far more aggressively rate-limited for unauthenticated CI runners.
MATUGEN_TAG=$(curl -fsSL -o /dev/null -w '%{url_effective}' "https://github.com/InioX/matugen/releases/latest" | sed 's#.*/tag/##')
MATUGEN_VERSION="${MATUGEN_TAG#v}"
curl -fsSL "https://github.com/InioX/matugen/releases/download/${MATUGEN_TAG}/matugen-${MATUGEN_VERSION}-x86_64.tar.gz" \
    | tar -xzf - -C /usr/bin/ matugen
chmod +x /usr/bin/matugen

### youtube-music (pear-devs/pear-desktop, formerly th-ch/youtube-music -- not in Fedora repos)
YTM_TAG=$(curl -fsSL -o /dev/null -w '%{url_effective}' "https://github.com/pear-devs/pear-desktop/releases/latest" | sed 's#.*/tag/##')
YTM_VERSION="${YTM_TAG#v}"
curl -fsSL "https://github.com/pear-devs/pear-desktop/releases/download/${YTM_TAG}/youtube-music-${YTM_VERSION}.x86_64.rpm" -o /tmp/ytm.rpm
dnf5 install -y /tmp/ytm.rpm
rm -f /tmp/ytm.rpm

### hydralauncher (hydralauncher/hydra -- not in Fedora repos)
HYDRA_TAG=$(curl -fsSL -o /dev/null -w '%{url_effective}' "https://github.com/hydralauncher/hydra/releases/latest" | sed 's#.*/tag/##')
HYDRA_VERSION="${HYDRA_TAG#v}"
curl -fsSL "https://github.com/hydralauncher/hydra/releases/download/${HYDRA_TAG}/hydralauncher-${HYDRA_VERSION}.x86_64.rpm" -o /tmp/hydra.rpm
dnf5 install -y /tmp/hydra.rpm
rm -f /tmp/hydra.rpm

### magic-wormhole-rs (Rust implementation, provides the wormhole-rs binary; not in Fedora repos)
CARGO_HOME=/tmp/cargo cargo install --locked magic-wormhole-cli --root /usr

### devbox (jetify-com/devbox, not in Fedora repos)
curl -fsSL https://releases.jetify.com/devbox -o /tmp/devbox-install.sh
FORCE=1 bash /tmp/devbox-install.sh
rm -f /tmp/devbox-install.sh

### colloid-icon-theme (vinceliuice/Colloid-icon-theme, not in Fedora repos)
git clone --depth=1 https://github.com/vinceliuice/Colloid-icon-theme.git /tmp/colloid-icon-theme
/tmp/colloid-icon-theme/install.sh -d /usr/share/icons -s all -t all
rm -rf /tmp/colloid-icon-theme

### ergogen (keyboard layout generator, npm-only)
npm install -g ergogen

### Cleanup
# Note: intentionally not running `dnf5 clean all` here. /var/cache is a
# buildah cache mount (--mount=type=cache in the Containerfile), so its
# contents are never part of the committed image layer regardless of whether
# they're cleaned -- but wiping it here would defeat the point of the cache
# mount by forcing every subsequent build to re-download every RPM.
