# Tailscale passwordless sudo

Replaces the old pkexec/fingerprint flow in `tailscale-toggle.sh` —
pkexec auth via fprintd was unreliable ("Not authorized" with no
password fallback). The toggle now uses the `tailscale-ctl` wrapper,
which needs these NOPASSWD sudoers entries.

## Install

```sh
cd ~/dotfiles/_patches/tailscale-sudo
sudo install -o root -g root -m 440 tailscale-sudoers /etc/sudoers.d/tailscale
sudo visudo -c   # must report "parsed OK"
```

## Why these four commands

`scripts/vpn/tailscale-ctl` (deployed to `/usr/local/bin/tailscale-ctl`
via `scripts/copy-scripts.sh`) runs:

- `sudo systemctl start tailscaled` — when the daemon is not running
- `sudo systemctl stop tailscaled`  — on "down" (stops DNS injection)
- `sudo tailscale up` / `sudo tailscale down`

The entries match the exact command + args, so nothing else is
passwordless.
