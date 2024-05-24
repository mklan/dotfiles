#!/usr/bin/env -S deno run -A --allow-env

import { hyprctl } from "../../lib/hyprctl.ts";

const [EVENT] = Deno.args[0].split(',');

const address = EVENT.split('>>')[1];

// Refocus new window to warp mouse
//hyprctl(`dispatch focuswindow address:0x${address}`)