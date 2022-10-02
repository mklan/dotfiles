# displays how long this system is being installed
sudo tune2fs -l /dev/mapper/lvm-root | grep 'Filesystem created:'