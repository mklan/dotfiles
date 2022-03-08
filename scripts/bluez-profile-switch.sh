card='6C_DD_BC_DE_64_B9'

sinks=$(pactl list short sinks)

if [[ $sinks = *bluez_output.${card}.a2dp-sink* ]]; then
    pactl set-card-profile bluez_card.${card} headset-head-unit-msbc
elif [[ $sinks = *bluez_output.${card}.headset-head-unit* ]]; then
    pactl set-card-profile bluez_card.${card} a2dp-sink
fi
