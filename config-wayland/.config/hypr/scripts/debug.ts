#!/usr/bin/env -S deno run -A --allow-env

import { execute } from "./utils/execute.ts";

(async () => {

  await execute('socat - "UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"', (data) => {
    console.log(data);
  })
})();