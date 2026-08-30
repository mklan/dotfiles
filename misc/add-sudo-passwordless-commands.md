sudo visudo

matze ALL=(ALL) NOPASSWD: /usr/bin/wg-quick up /home/matze/wireguard/home.conf, /usr/bin/wg-quick down /home/matze/wireguard/home.conf, /usr/sbin/resolvconf -u
