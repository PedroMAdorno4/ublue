# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A custom [bootc](https://github.com/bootc-dev/bootc) OCI image built on top of `ghcr.io/ublue-os/bazzite:stable`, plus a full set of personal [chezmoi](https://www.chezmoi.io) dotfiles for a Hyprland/niri Wayland desktop. It's forked from the ublue-os `image-template`. The image bakes in packages/services at build time; the dotfiles are applied to a user's home directory at first login (or manually via `just chezmoi-apply`).

Two independent layers to keep in mind when editing:
1. **Image layer** (`Containerfile`, `build_files/`, `system_files/`, `disk_config/`) — what gets baked into the OCI image and, from it, disk images.
2. **Dotfiles layer** (`dotfiles/`) — chezmoi source state, copied into the image at `/usr/share/ublue-dotfiles` and applied per-user via a systemd unit (`chezmoi-init.service`), not edited in place on a running system.

## Commands

Everything is driven through `just` (see `Justfile`). Env vars (`image_name`, `repo_organization`, etc.) come from `image-template.env`, auto-loaded via `set dotenv-load`.

- `just check` — validate Justfile/`*.just` syntax (`just --fmt --check`). Run before committing Justfile changes.
- `just fix` — auto-format Justfile syntax.
- `just lint` — shellcheck every `*.sh` file in the repo.
- `just format` — shfmt every `*.sh` file in the repo.
- `just build` — `podman build` the Containerfile into a local image (`localhost/<image_name>:<tag>` by default).
- `just build-qcow2` / `build-raw` / `build-iso` — build a disk image from the container image via bootc-image-builder (uses `disk_config/disk.toml` or `iso*.toml`); `rebuild-*` variants rebuild the container image first.
- `just run-vm-qcow2` / `run-vm-raw` / `run-vm-iso` — build (if needed) and boot the disk image in a browser-based VM (qemux/qemu container), opening `http://localhost:<port>`.
- `just spawn-vm` — boot an existing disk image via `systemd-vmspawn` instead of the container-based VM runner.
- `just chezmoi-apply [users...]` — apply `dotfiles/` via chezmoi for the given local users (defaults to all real users, UID 1000–59999). Useful for testing dotfile changes without a full image rebuild — this is the primary iteration loop for the dotfiles layer.
- `just clean` — remove build artifacts (`*_build*`, `output/`, manifest/changelog files).

There is no separate test suite; correctness is verified by `just check`/`just lint` plus actually building the image and/or applying the dotfiles.

## Image layer architecture

- **Containerfile**: multi-stage. A `FROM scratch AS ctx` stage stages `build_files/`, `system_files/`, and `dotfiles/` so they're available to the build without being copied into the final image layers. The real build stage starts `FROM ghcr.io/ublue-os/bazzite:stable@sha256:...` (pinned by digest — update deliberately, not casually), does a `/opt` fixup (bazzite symlinks `/opt` -> `/var/opt`, which breaks RPM installs that write to `/opt`; this repo makes `/opt` a real directory instead), then runs `build_files/build.sh` via a bind-mount of the `ctx` stage plus cache mounts for `/var/cache` and `/var/log`. Ends with `bootc container lint`.
- **build_files/build.sh**: the actual customization script (`set -ouex pipefail`). In order: recreates `/var/roothome` and `/var/usrlocal` (normally materialized by an ostree tmpfiles rule that doesn't run during image build — needed because chezmoi/npm/etc. mkdir through those symlinks), copies `system_files/` to `/`, copies `dotfiles/` into `/usr/share/ublue-dotfiles` (so chezmoi can apply them offline later), enables COPR/Terra/Brave/GitHub CLI repos, does one big `dnf5 install -y --skip-unavailable --skip-broken ...` package list, disables the COPRs again, installs fonts (including a Nerd Font fetched from GitHub releases), enables systemd services, and installs several tools that aren't packaged for Fedora by building/fetching them directly (oh-my-posh, antidote, wl-gammarelay-rs via cargo, matugen, youtube-music, hydralauncher, magic-wormhole-rs via cargo, devbox, Colloid icon theme, ergogen via npm). When adding a package, prefer adding it to the existing `dnf5 install` list; when adding something not in Fedora/COPR/Terra repos, follow the existing pattern of a dedicated commented section that resolves the latest GitHub release tag via the `/releases/latest` redirect (not the rate-limited `api.github.com` endpoint) and cleans up temp files.
- **system_files/**: raw files copied verbatim to `/` (mirrors real root paths, e.g. `system_files/etc/hosts` -> `/etc/hosts`). Use for static system-level config (systemd units/overrides, udev rules, polkit rules, sudoers drop-ins, wireplumber/bluetooth config) that doesn't belong in a package.
- **disk_config/**: bootc-image-builder TOML configs (`disk.toml` for qcow2/raw, `iso-gnome.toml`/`iso-kde.toml` for ISOs) — filesystem sizing and installer customizations for disk image builds.
- **.github/workflows/build.yml** / **build-disk.yml**: CI that runs `just check`, builds and pushes the image to GHCR, and optionally builds/uploads disk images. Not modified as part of routine dotfile/package work.

## Dotfiles layer architecture

- Source of truth is `dotfiles/`, using chezmoi's naming convention (`dot_config` -> `.config`, `executable_foo` -> `foo` with the exec bit, `run_once_*` -> one-time setup scripts, `private_*` -> mode 600).
- `dotfiles/.chezmoi.toml.tmpl` prompts for `username` (quatro/padorno), `role` (personal/work), and `pcType` (desktop/laptop) on first apply, and derives `email`/`name` from those — templates elsewhere in `dot_config/` can branch on `.role`/`.pcType`/`.username`.
- `dotfiles/run_once_after_setup.sh.tmpl` and `run_once_after_dconf.sh` handle one-time, non-declarative setup that can't be expressed as a plain dotfile: chmod'ing scripts in `dot_local/bin`, cloning tmux/yazi plugins, creating XDG dirs, enabling user systemd units (`swww-daemon`, `wallpaper-cycle.timer`), and dconf writes (virt-manager connection defaults).
- Desktop stack is Hyprland/niri (Wayland compositors) with waybar, wofi, hyprlock/hyprpolkitagent, awww (wallpaper daemon replacing mpvpaper — see git history; the Terra package was later renamed from `swww` to `awww` upstream, same CLI/socket protocol, just the binary/package name changed), matugen (Material-You theming), noctalia. `dot_local/bin/` holds small executable helper scripts (`wallpaper-cycle`, `switch-audio`, `projectfinder`) referenced by keybinds/systemd units elsewhere in the dotfiles.
- On a live image, dotfiles are applied by the user-level `chezmoi-init.service` (`system_files/etc/systemd/user/chezmoi-init.service`), which runs `chezmoi init --apply --source=/usr/share/ublue-dotfiles --promptDefaults` once per user (guarded by the presence of `~/.config/chezmoi/chezmoi.toml`). To re-apply after editing dotfiles in this repo, use `just chezmoi-apply` rather than waiting for a rebuild.

## Conventions worth preserving

- Non-obvious decisions in `build.sh` and the `Containerfile` are explained with comments right above the relevant line (cache mounts, `/opt` handling, `/var/roothome` fixup, GitHub rate-limit avoidance). Keep following that pattern — add a comment when a line would otherwise look removable or wrong, not otherwise.
- Package installs use `--skip-unavailable --skip-broken` deliberately so one bad/retired package doesn't fail the whole transaction; don't drop those flags without checking why a specific package needs them.
- The base image digest in the `Containerfile` and the COPR enable/disable pairs in `build.sh` are intentionally symmetric (enable near the top, disable right after the package installs that need them) — keep new COPR usage consistent with that pattern.
