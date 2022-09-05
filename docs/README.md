## Misc
### Add open in new terminal to Thunar

Thunar -> Edit -> Configure custom actions...

Open in new Terminal: `sh -c 'cd %f;urxvt'`

## Troubleshooting

### Firefox tearing / preformance

set `layers.acceleration.force-enabled` to true in `about:config`

### Blueman does not open Devices

to fix run:

`dbus-update-activation-environment DISPLAY`


## cleanup

remove orphans:

sudo pacman -Rns $(pacman -Qtdq)


keep 50MB of latest logs:

sudo journalctl --vacuum-size=50M
