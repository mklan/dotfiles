# Fix brightness keys

`sudo vim /etc/default/grub`     

add `acpi_backlight=native` to `GRUB_CMDLINE_LINUX_DEFAULT`

like `GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet acpi_backlight=native"`

`sudo  grub-mkconfig -o /boot/grub/grub.cfg`

reboot