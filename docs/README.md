## cleanup

remove orphans:

sudo pacman -Rns $(pacman -Qtdq)


keep 50MB of latest logs:

sudo journalctl --vacuum-size=50M
