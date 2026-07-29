#!/bin/bash

# Reload the dark (OLED) Everforest theme.
# For full dark/light switching use: switch-theme.sh [dark|light]

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
exec "$DOTFILES_DIR/scripts/switch-theme.sh" dark