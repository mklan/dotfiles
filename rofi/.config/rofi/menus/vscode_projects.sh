#!/usr/bin/bash

# src: https://github.com/knadh/rofi-vscode-projects

# Path to the projects.json file (vscode alefragnani project manager)
SRC=~/.config/Code\ -\ OSS/User/globalStorage/alefragnani.project-manager/projects.json

prj=$(jq -r "sort_by(.name) | .[].name" < "$SRC" | rofi -dmenu -p "vscode project" $@)

# If there was a selection, find its path from the src file and launch vscode.
if [ -n "$prj" ]; then
    prjpath=$(jq -r --arg prj "$prj" '.[] | select(.name==$prj) | .rootPath' < "$SRC")
    code $prjpath
fi