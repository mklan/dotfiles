#!/usr/bin/env -S deno run -A --allow-env

import { hyprctl } from "../../lib/hyprctl.ts";
import { getActiveWindow } from "../../utils/monitor.ts";

const { address } = await getActiveWindow();

//hyprctl(`dispatch focuswindow address:${address}`)