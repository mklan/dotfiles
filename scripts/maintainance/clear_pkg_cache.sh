# Clean yay cache (keep 1 previous version)
yay -Sc

# Clean pacman cache (keep 1 previous version)
sudo pacman -Sc

# More aggressive pacman cache clean (deletes ALL cached packages)
sudo pacman -Scc
