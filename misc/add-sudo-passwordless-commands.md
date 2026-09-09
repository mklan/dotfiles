sudo visudo

matze ALL=(ALL) NOPASSWD: /usr/bin/wg-quick up /home/matze/wireguard/home.conf, /usr/bin/wg-quick down /home/matze/wireguard/home.conf, /usr/sbin/resolvconf -u

# tailscale (bar toggle) — as a drop-in instead, see _patches/tailscale-sudo/
# sudo install -o root -g root -m 440 _patches/tailscale-sudo/tailscale-sudoers /etc/sudoers.d/tailscale
