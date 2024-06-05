#!/usr/bin/env -S deno run -A --allow-env


import { execute as $ } from "./utils/execute.ts";

let [action] = Deno.args;


await $(`pulseaudio-control --volume-max 130 ${action}`);
const [value] = await $(`pulseaudio-control output`).then(r => r.split('%'));

await $(`dunstify -a "changeVolume" -u low -i audio-volume-high -h string:x-dunst-stack-tag:myvolume -h int:value:${value} "Volume: ${value}%"`);
