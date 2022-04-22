card='6C_DD_BC_DE_64_B9'

sinks=$(pactl list short sinks)

if [[ $sinks = *bluez_output.${card}.a2dp-sink* ]]; then
    echo ""
elif [[ $sinks = *bluez_output.${card}.headset-head-unit* ]]; then
    echo ""
fi