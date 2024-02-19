import { hyprctl } from "./lib/hyprctl.ts";
import { getFocusedMonitor } from "./utils/monitor.ts";
import { sleep } from "./utils/sleep.ts";

const pwidth = 640;
const pheight = 360;
const margin = 40;


const monitor = await getFocusedMonitor();


await hyprctl(
  'dispatch togglefloating', 
  'dispatch pin', 
  `dispatch resizeactive exact ${pwidth} ${pheight}`,
  'dispatch centerwindow', 
);

// await sleep(10);

await hyprctl(`dispatch moveactive ${parseInt(monitor.width)/2 - pwidth / 2 - margin} ${parseInt(monitor.height)/2 - pheight / 2 - margin}`);