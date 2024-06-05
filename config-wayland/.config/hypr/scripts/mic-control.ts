#!/usr/bin/env -S deno run -A --allow-env
import { execute as $ } from "./utils/execute.ts";

await $('amixer set Capture toggle');

const isOn = await $('amixer get Capture').then(o => o.includes('[on]'));
const ledState = isOn ? 0 : 1;

await $(`notify-send "mic: ${isOn}"`)

// src: https://www.reddit.com/r/LinuxOnThinkpad/comments/n01h4x/comment/gw5dhdy/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
await $(`echo "${ledState}" | tee "/sys/class/leds/platform::micmute/brightness"`);