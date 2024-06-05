current_hour=$(date +%H)

in=3;
out=6;
waybar_shader=shwartz_bar

if ((current_hour % 2 == 0)); then
    in=2;
    out=4;
    waybar_shader=shwartz_bar_shift
fi

hyprctl --instance 0 keyword general:gaps_in $in;
hyprctl --instance 0 keyword general:gaps_out $out;

hyprshade off
hyprshade on $waybar_shader