yay -S ddcutil
sudo modprobe i2c-dev
sudo ddcutil detect
sudo ddcutil setvcp 10 50
sudo ddcutil setvcp 10 100
sudo ddcutil setvcp 10 1